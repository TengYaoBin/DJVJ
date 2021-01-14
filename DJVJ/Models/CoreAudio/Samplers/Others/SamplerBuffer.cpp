//
//  SamplerBuffer.cpp
//  VisWiz
//
//  Created by Joe Best on 02/03/2015.
//  Copyright (c) 2015 Joe Best. All rights reserved.
//

#include "SamplerBuffer.h"

SamplerBuffer::SamplerBuffer() : m_data(), m_read_index(0), m_write_index(0) {}

SamplerSlice SamplerBuffer::get_slice()
{
	uint32 write_index = m_write_index;
	uint32 read_index = m_read_index;

	// deal with wraparound of indexes
	int32 index_diff = write_index - read_index;
	if (index_diff < 0)
	{
		index_diff += BUFFER_SIZE;
	}

	if (index_diff >= SAMPLES_PER_SLICE)
	{
		SamplerSlice slice(SAMPLES_PER_SLICE, &m_data[read_index]);
		m_read_index = (read_index + SAMPLES_PER_SLICE) % BUFFER_SIZE;

		return slice;
	}

	return SamplerSlice();
}

uint32 SamplerBuffer::write_space() const
{
	// this deals with wraparound of indexes
	int32 index_diff = m_write_index - m_read_index;
	if (index_diff < 0)
	{
		index_diff += BUFFER_SIZE;
	}

	// subtracting the extra SAMPLES_PER_SLICE to leave one slice at all times, as this may be currently being read
	return BUFFER_SIZE - SAMPLES_PER_SLICE - index_diff;
}

uint32 SamplerBuffer::write_position() const { return m_write_index; }

void SamplerBuffer::advance_write_position(uint32 diff) { m_write_index = (m_write_index + diff) % BUFFER_SIZE; }

float32& SamplerBuffer::operator[](uint32 i) { return m_data[i % BUFFER_SIZE]; }