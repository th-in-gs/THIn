//
//  THIn.m
//  THIn
//
//  Created by James Montgomerie on 10/12/2012.
//  Copyright (c) 2012 James Montgomerie. All rights reserved.
//

#import "THIn.h"

@interface THInMessageProxy : NSProxy
@end

@implementation THInMessageProxy {
    id _target;
    NSTimeInterval _delay;
}

- (id)initWithTarget:(id)target delay:(NSTimeInterval)delay
{
    _target = target;
    _delay = delay;
    
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    __weak id wTarget = _target;
    
    [invocation setTarget:nil];
    [invocation retainArguments];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, _delay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        id obj = wTarget;
        if(obj) {
            [invocation invokeWithTarget:obj];
        }
    });
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [_target methodSignatureForSelector:aSelector];
}

@end

@implementation NSObject (THIn)

- (instancetype)thIn:(NSTimeInterval)delay
{
    return (id)[[THInMessageProxy alloc] initWithTarget:self delay:delay];
}

- (void)thIn:(NSTimeInterval)delay do:(void(^)(id obj))block
{
    __weak id wSelf = self;

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        id obj = wSelf;
        if(obj) {
            block(obj);
        }
    });
}

@end


@implementation THInWeakTimer {
    void(^_block)(void);
    CFRunLoopTimerRef _runLoopTimer;
}

- (id)initWithDelay:(NSTimeInterval)delay do:(void (^)(void))block
{
    return [self initWithFireTime:CFAbsoluteTimeGetCurrent() + delay do:block];
}

- (id)initWithFireTime:(CFAbsoluteTime)fireTime do:(void (^)(void))block
{
    _block = [block copy];
    
    __weak THInWeakTimer *wSelf = self;
    _runLoopTimer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault,
                                                    fireTime,
                                                    0,
                                                    0,
                                                    0,
                                                    ^(CFRunLoopTimerRef timer) {
                                                        [wSelf _fire];
                                                    });
    CFRunLoopAddTimer(CFRunLoopGetMain(), _runLoopTimer, kCFRunLoopCommonModes);
    
    return self;
}

- (BOOL)isValid
{
    return _runLoopTimer && CFRunLoopTimerIsValid(_runLoopTimer);
}

- (CFAbsoluteTime)fireTime
{
    CFAbsoluteTime fireTime = -1;
    if(_runLoopTimer && CFRunLoopTimerIsValid(_runLoopTimer)) {
        fireTime = CFRunLoopTimerGetNextFireDate(_runLoopTimer);
    }
    return fireTime;
}

- (void)setFireTime:(CFAbsoluteTime)fireTime
{
    if(_runLoopTimer && CFRunLoopTimerIsValid(_runLoopTimer)) {
        CFRunLoopTimerSetNextFireDate(_runLoopTimer, fireTime);
    } 
}

- (void)_fire
{
    if(_block) {
        _block();
        [self invalidate];
    }
}

- (void)invalidate
{
    if(_runLoopTimer) {
        if(CFRunLoopTimerIsValid(_runLoopTimer)) {
            CFRunLoopTimerInvalidate(_runLoopTimer);
        }
        CFRelease(_runLoopTimer);
        _runLoopTimer = nil;
        _block = nil;
    }
}

- (void)dealloc
{
    [self invalidate];
}

@end