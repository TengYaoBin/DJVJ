//
//  MicSampler.cpp
//  VisWiz
//
//  Created by Joe Best on 28/08/2014.
//  Copyright (c) 2014 Joe Best. All rights reserved.
//

#import "MicSampler.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioSession.h>

#import "CAXException.h"
#import "CAStreamBasicDescription.h"
#import "SamplerBuffer.h"

// This does the render callback, apparently it's best not to send
// objective-c messages in render callbacks
class MicSamplerInternal
{
    public:
	MicSamplerInternal();
	~MicSamplerInternal();
	SamplerSlice get_slice();

    private:
	static OSStatus render_callback(void* in_ref_con, AudioUnitRenderActionFlags* io_action_flags,
					const AudioTimeStamp* in_time_stamp, UInt32 in_bus_number,
					UInt32 in_number_frames, AudioBufferList* io_data);

	OSStatus perform_render(AudioUnitRenderActionFlags* io_action_flags, const AudioTimeStamp* in_time_stamp,
				UInt32 in_bus_number, UInt32 in_number_frames, AudioBufferList* io_data);

	AudioUnit m_audio_unit;
	SamplerBuffer m_buffer;
};

@interface MicSampler ()
{
	MicSamplerInternal m_internal;
}

@end

@implementation MicSampler

- (SamplerSlice)get_slice { return m_internal.get_slice(); }
- (void)cleanup {}

@end

MicSamplerInternal::MicSamplerInternal() : m_audio_unit(nullptr), m_buffer()
{
	// Configure the audio session
	AVAudioSession* sessionInstance = [AVAudioSession sharedInstance];

	// we are going to record so we pick that Package
	NSError* error = nil;
	[sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
	XThrowIfError((OSStatus)error.code, "couldn't set session's audio Package");

	// set the buffer duration to 5 ms
	NSTimeInterval bufferDuration = .005;
	[sessionInstance setPreferredIOBufferDuration:bufferDuration error:&error];
	XThrowIfError((OSStatus)error.code, "couldn't set session's I/O buffer duration");

	// set the session's sample rate
	[sessionInstance setPreferredSampleRate:44100 error:&error];
	XThrowIfError((OSStatus)error.code, "couldn't set session's preferred sample rate");
	
	// activate the audio session
	[[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error != nil) {
        return;
    }
	XThrowIfError((OSStatus)error.code, "couldn't set session active");

	try
	{
		// Create a new instance of AURemoteIO

		AudioComponentDescription desc;
		desc.componentType = kAudioUnitType_Output;
		desc.componentSubType = kAudioUnitSubType_RemoteIO;
		desc.componentManufacturer = kAudioUnitManufacturer_Apple;
		desc.componentFlags = 0;
		desc.componentFlagsMask = 0;

		AudioComponent comp = AudioComponentFindNext(NULL, &desc);
		XThrowIfError(AudioComponentInstanceNew(comp, &m_audio_unit),
			      "couldn't create a new instance of AURemoteIO");

		//  Enable input and output on AURemoteIO
		//  Input is enabled on the input scope of the input element
		//  Output is enabled on the output scope of the output element

		UInt32 one = 1;
		XThrowIfError(AudioUnitSetProperty(m_audio_unit, kAudioOutputUnitProperty_EnableIO,
						   kAudioUnitScope_Input, 1, &one, sizeof(one)),
			      "could not enable input on AURemoteIO");

		/*XThrowIfError(AudioUnitSetProperty(m_audio_unit, kAudioOutputUnitProperty_EnableIO,
		     kAudioUnitScope_Output, 0, &one, sizeof(one)),
		     "could not enable output on AURemoteIO");*/

		// Explicitly set the input and output client formats
		// sample rate = 44100, num channels = 1, format = 32 bit
		// floating point

		CAStreamBasicDescription ioFormat =
		    CAStreamBasicDescription(44100, 1, CAStreamBasicDescription::kPCMFormatFloat32, false);
		XThrowIfError(AudioUnitSetProperty(m_audio_unit, kAudioUnitProperty_StreamFormat,
						   kAudioUnitScope_Output, 1, &ioFormat, sizeof(ioFormat)),
			      "couldn't set the input client format on AURemoteIO");
		XThrowIfError(AudioUnitSetProperty(m_audio_unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input,
						   0, &ioFormat, sizeof(ioFormat)),
			      "couldn't set the output client format on AURemoteIO");

		// Set the MaximumFramesPerSlice property. This property is used
		// to describe
		// to an audio unit the maximum number
		// of samples it will be asked to produce on any single given
		// call to
		// AudioUnitRender
		UInt32 maxFramesPerSlice = 1024;
		XThrowIfError(AudioUnitSetProperty(m_audio_unit, kAudioUnitProperty_MaximumFramesPerSlice,
						   kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(UInt32)),
			      "couldn't set max frames per slice on AURemoteIO");

		// Get the property value back from AURemoteIO. We are going to
		// use this
		// value to allocate buffers accordingly
		UInt32 propSize = sizeof(UInt32);
		XThrowIfError(AudioUnitGetProperty(m_audio_unit, kAudioUnitProperty_MaximumFramesPerSlice,
						   kAudioUnitScope_Global, 0, &maxFramesPerSlice, &propSize),
			      "couldn't get max frames per slice on AURemoteIO");

		// Set the render callback on AURemoteIO
		AURenderCallbackStruct renderCallback;
		renderCallback.inputProc = MicSamplerInternal::render_callback;
		renderCallback.inputProcRefCon = this;
		XThrowIfError(AudioUnitSetProperty(m_audio_unit, kAudioUnitProperty_SetRenderCallback,
						   kAudioUnitScope_Input, 0, &renderCallback, sizeof(renderCallback)),
			      "couldn't set render callback on AURemoteIO");

		// Initialize the AURemoteIO instance
		XThrowIfError(AudioUnitInitialize(m_audio_unit), "couldn't initialize AURemoteIO instance");

		// Start the audioUnit
		XThrowIfError(AudioOutputUnitStart(m_audio_unit), "couldn't start AURemoteIO instance");
	}

	catch (CAXException& e)
	{
		NSLog(@"Error returned from setupIOUnit: %d: %s", (int)e.mError, e.mOperation);
	}
	catch (...)
	{
		NSLog(@"Unknown error returned from setupIOUnit");
	}
}

MicSamplerInternal::~MicSamplerInternal() { AudioOutputUnitStop(m_audio_unit); }

SamplerSlice MicSamplerInternal::get_slice() { return m_buffer.get_slice(); }

OSStatus MicSamplerInternal::render_callback(void* in_ref_con, AudioUnitRenderActionFlags* io_action_flags,
					     const AudioTimeStamp* in_time_stamp, UInt32 in_bus_number,
					     UInt32 in_number_frames, AudioBufferList* io_data)
{
	return static_cast<MicSamplerInternal*>(in_ref_con)
	    ->perform_render(io_action_flags, in_time_stamp, in_bus_number, in_number_frames, io_data);
}

OSStatus MicSamplerInternal::perform_render(AudioUnitRenderActionFlags* io_action_flags,
					    const AudioTimeStamp* in_time_stamp, UInt32 in_bus_number,
					    UInt32 in_number_frames, AudioBufferList* io_data)
{
	// MOVE ALL OF THIS STUFF TO COMMON BASE CLASS OR SOMETHING, MAKE IT KNOWN THAT THIS IS SINGLE PRODUCER SINGLE
	// CONSUMER
	OSStatus err = noErr;

	// we are calling AudioUnitRender on the input bus of AURemoteIO
	// this will store the audio data captured by the microphone in ioData
	err = AudioUnitRender(m_audio_unit, io_action_flags, in_time_stamp, 1, in_number_frames, io_data);

	float32* data = static_cast<float32*>(io_data->mBuffers[0].mData);

	uint32 write_space = m_buffer.write_space();
	if (write_space > 0)
	{
		uint32 n = MIN(write_space, in_number_frames);
		uint32 write_pos = m_buffer.write_position();

		for (uint32 i = 0; i < in_number_frames && i < write_pos; ++i)
		{
			m_buffer[write_pos + i] = data[i];
		}

		m_buffer.advance_write_position(n);
	}

	// This stops the audio from coming out of the speakers, causing potential feedback
	for (uint32 i = 0; i < in_number_frames; ++i)
	{
		data[i] = 0.0f;
	}

	return err;
}
