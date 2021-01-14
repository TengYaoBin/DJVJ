//
//  Sampler.h
//  VisWiz
//
//  Created by Joe Best on 11/01/2015.
//  Copyright (c) 2015 Joe Best. All rights reserved.
//

#include "SamplerBuffer.h"
#import <AVFoundation/AVFoundation.h>

@protocol Sampler <NSObject>

// Returns next available slice if available, otherwise returns null.
- (SamplerSlice)get_slice;
- (void)cleanup;

@end
