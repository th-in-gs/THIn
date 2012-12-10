//
//  THIn.h
//  THIn
//
//  Created by James Montgomerie on 10/12/2012.
//  Copyright (c) 2012 James Montgomerie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (THIn)

- (id)thIn:(NSTimeInterval)delay;

- (void)thIn:(NSTimeInterval)delay do:(void(^)(id obj))block;

@end
