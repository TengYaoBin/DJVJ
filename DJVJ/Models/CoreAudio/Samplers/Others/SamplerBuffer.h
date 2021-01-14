//
//  SamplerBuffer.h
//  VisWiz
//
//  Created by Joe Best on 02/03/2015.
//  Copyright (c) 2015 Joe Best. All rights reserved.
//

#ifndef __VisWiz__SamplerBuffer__
#define __VisWiz__SamplerBuffer__

#include <atomic>

#include "Types.h"

struct SamplerSlice;

// Lock-free buffer to contain the slices of audio samples, NOTE: single-producer, single-consumer
class SamplerBuffer
{
    public:
	SamplerBuffer();
	SamplerSlice get_slice();      // get a slice, returns a SamplerSlice containing null on failure
	uint32 write_space() const;    // number of samples which there is space to write at present, make more space by
				       // reading with get_slice
	uint32 write_position() const; // current write position, use this as the starting point to write new samples,
				       // and then advance the write position when done
	void advance_write_position(uint32); // advances the write position, to be used after writing data to the
					     // buffer, not done automatically as involves manipulating an atomic
					     // variable which can be expensive
	float32& operator[](uint32);	 // get element in buffer at index, but automatically wraps the index

	static constexpr uint32 SAMPLES_PER_SLICE = 1024;

    private:
	static constexpr uint32 BUFFER_SIZE = SAMPLES_PER_SLICE * 64;

	float32 m_data[BUFFER_SIZE];
	std::atomic<uint32> m_write_index;
	std::atomic<uint32> m_read_index;
};

struct SamplerSlice
{
	uint32 sample_count;
	float32* samples;

	SamplerSlice() : SamplerSlice(0, nullptr) {}

	SamplerSlice(const uint32 sample_count, float* const samples) : sample_count(sample_count), samples(samples) {}
};

#endif /* defined(__VisWiz__SamplerBuffer__) */
