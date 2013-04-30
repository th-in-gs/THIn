//
//  THIn.h
//  THIn
//
//  Created by James Montgomerie on 10/12/2012.
//  Copyright (c) 2012 James Montgomerie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (THIn)

- (instancetype)thIn:(NSTimeInterval)delay;

- (void)thIn:(NSTimeInterval)delay do:(void(^)(id obj))block;

@end

@interface THInWeakTimer : NSObject

- (id)initWithDelay:(NSTimeInterval)delay do:(void (^)(void))block;
- (id)initWithFireTime:(CFAbsoluteTime)fireTime do:(void (^)(void))block;
- (void)invalidate;

@property (nonatomic, assign) CFAbsoluteTime fireTime;
@property (nonatomic, assign, readonly, getter=isValid) BOOL valid;

@end