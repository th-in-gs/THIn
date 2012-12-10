//
//  THIn.m
//  THIn
//
//  Created by James Montgomerie on 10/12/2012.
//  Copyright (c) 2012 James Montgomerie. All rights reserved.
//

#import "THIn.h"
#import <objc/message.h>

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
    
    [invocation retainArguments];
    [invocation setTarget:nil];
    
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

- (id)thIn:(NSTimeInterval)delay
{
    return [[THInMessageProxy alloc] initWithTarget:self delay:delay];
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
