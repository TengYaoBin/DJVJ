//
//  ITunesSampler.m
//  VisWiz
//
//  Created by Joe Best on 11/01/2015.
//  Copyright (c) 2015 Joe Best. All rights reserved.
//

// Header for this file
#import "ITunesSampler.h"

// Obj-C libs
#import <AVFoundation/AVAssetReader.h>
#import <AVFoundation/AVAssetReaderOutput.h>
#import <AVFoundation/AVAudioSettings.h>
#import <CoreMedia/CMTime.h>
#import <MediaPlayer/MPMusicPlayerController.h>

@interface ITunesSampler ()
{
	SamplerBuffer m_buffer;
	NSThread* m_loading_thread;
}

@end

@implementation ITunesSampler

- (id)init
{
	self = [super init];
	if (self)
	{
		m_loading_thread = [[NSThread alloc] initWithTarget:self selector:@selector(thread_main) object:nil];
		[m_loading_thread start];
	}

	return self;
}

- (void)dealloc
{
    // in case cleanup is not called first
	[m_loading_thread cancel];
	while (!m_loading_thread.isFinished)
	{
	}
}

- (void)cleanup
{
    [m_loading_thread cancel];
}

- (SamplerSlice)get_slice { return m_buffer.get_slice(); }

- (void)thread_main
{
	@autoreleasepool
	{
		MPMusicPlayerController* music_player = [MPMusicPlayerController systemMusicPlayer];
		MPMediaItem* now_playing = nil;
		AVAssetReader* reader = nil;
		AVAssetReaderTrackOutput* reader_output = nil;
		NSTimeInterval current_playback_time = 0;
		char* buffer = nullptr;
		uint32 buffer_size = 0;

		while ([NSThread currentThread].isCancelled == NO)
		{
			@autoreleasepool
			{
				try
				{
					// Set up reader when the track has changed
					// Or when the playback time has changed too much since last time, so the reader
					// should be
					// stopped and resumed at the right bit (too much is judged to be 0.25s, which
					// is about 10k of
					// data)
					if (now_playing != music_player.nowPlayingItem || (music_player.currentPlaybackTime - current_playback_time) > 0.25f)
					{
						now_playing = music_player.nowPlayingItem;
						reader = nil;
						reader_output = nil;

						NSURL* url = [now_playing valueForProperty:MPMediaItemPropertyAssetURL];

						// url will be nil if there is DRM
						if (url != nil)
						{
							AVURLAsset* asset = [AVURLAsset URLAssetWithURL:url options:nil];
							NSError* error = nil;
							reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];

							if (error != nil)
							{
								NSLog(@"Error initialising AVAssetReader");
								NSLog(@"%@", error.localizedDescription);
								continue;
							}

							AVAssetTrack* track = [asset.tracks objectAtIndex:0];

							NSDictionary* output_settings = [[NSDictionary alloc]
							    initWithObjectsAndKeys:

								[NSNumber numberWithInt:kAudioFormatLinearPCM],
								AVFormatIDKey, [NSNumber numberWithInt:44100],
								AVSampleRateKey, [NSNumber numberWithInt:1],
								AVNumberOfChannelsKey, [NSNumber numberWithInt:32],
								AVLinearPCMBitDepthKey, [NSNumber numberWithBool:NO],
								AVLinearPCMIsBigEndianKey,
								[NSNumber numberWithBool:YES], AVLinearPCMIsFloatKey,
								[NSNumber numberWithBool:NO],
								AVLinearPCMIsNonInterleaved, nil];

							reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:track outputSettings:output_settings];

							CMTime start = CMTimeMakeWithSeconds(music_player.currentPlaybackTime, 1000000);
							CMTime end = asset.duration;
							reader.timeRange = CMTimeRangeFromTimeToTime(start, end);
							[reader addOutput:reader_output];

							// Important to know, the reader apparently fades the first
							// 1024ish samples, so if that's a problem, start the reader a
							// bit earlier and then skip those first 1024 samples
							[reader startReading];

							current_playback_time = music_player.currentPlaybackTime;
						}
					}

					// When resuming from background, status will become failed, so null
					// out now_playing to force the asset reader to be recreated

					if (reader.status == AVAssetReaderStatusFailed)
					{
						now_playing = nil;
						continue;
					}

					CMSampleBufferRef sample_buffer = [reader_output copyNextSampleBuffer];
					if (sample_buffer == NULL)
					{
						continue;
					}

					CMBlockBufferRef block_buffer = CMSampleBufferGetDataBuffer(sample_buffer);

					uint32 block_size = uint32(CMBlockBufferGetDataLength(block_buffer));
					if (block_size > buffer_size)
					{
						if (buffer != nullptr)
						{
							delete[] buffer;
							buffer = nullptr;
						}

						buffer_size = block_size;
						buffer = new char[buffer_size];
					}

					char* returned_pointer = nullptr;
					OSStatus status = CMBlockBufferAccessDataBytes(block_buffer, 0, block_size,
										       buffer, &returned_pointer);
					if (status != kCMBlockBufferNoErr)
					{
						NSLog(@"status != kCMBlockBufferNoErr");
						continue;
					}

					const uint32 num_samples = block_size / sizeof(float);
					float32* samples = reinterpret_cast<float32*>(returned_pointer);
					uint32 sample = 0;
					constexpr double INV_SAMPLE_RATE = 1.0 / 44100.0;

					while ([NSThread currentThread].isCancelled == NO && sample != num_samples)
					{
						@autoreleasepool
						{
							// this used to be in the while() above, but had to move it
							// inside this autoreleasepool block as it was causing memory
							// leaks, for some reason..
							if (music_player.nowPlayingItem != now_playing)
							{
								break;
							}

							const NSTimeInterval time_to_catch_up = music_player.currentPlaybackTime - current_playback_time;
							const uint32 samples_to_catch_up = time_to_catch_up * 44100.0;
							const uint32 space_in_buffer = m_buffer.write_space();
							const uint32 num_unread_samples = num_samples - sample;
							const uint32 samples_to_write = MIN(MIN(samples_to_catch_up, space_in_buffer), num_unread_samples);
							const uint32 write_position = m_buffer.write_position();

							for (uint32 i = 0; i < samples_to_write; ++i)
							{
								m_buffer[write_position + i] = samples[sample];
								++sample;
							}

							m_buffer.advance_write_position(samples_to_write);

							current_playback_time += samples_to_write * INV_SAMPLE_RATE;
						}
					}

					CFRelease(sample_buffer);
				}
				catch (NSException* e)
				{
					NSLog(@"%@", e);
				}
			}
		}

		if (buffer != nullptr)
		{
			delete[] buffer;
			buffer = nullptr;
		}
	}
}

@end
