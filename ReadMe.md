# THIn

© 2013 James Montgomerie  
jamie@montgomerie.net, [http://www.blog.montgomerie.net/](http://www.blog.montgomerie.net/)  
jamie@th.ingsmadeoutofotherthin.gs, [http://th.ingsmadeoutofotherthin.gs/](http://th.ingsmadeoutofotherthin.gs/)  

## What it is

- Three easy ways to do things later in Cocoa/Cocoa Touch.
- Simpler than `dispatch_after`, `-performSelector:withObject:afterDelay:` and `NSTimer`

## How it works

Three ways! All call back on the main thread/runloop/dispatch queue.

1. A Category on `NSObject` defines a `-thIn:` method takes an `NSTimeInterval` and returns a proxy object that will call any methods called on it after the interval (the recently new `instancetype` return type makes this type safe too!). 

    ```ObjC
    [[self thIn:3] doYourThingWithThisArray:@[ @"Everybody", @"to", @"the", @"limit!" ]]
    ```

2. A Category on `NSObject` defines a `-thIn:do:` method takes an `NSTimeInterval` and a block, and calls them after the interval.

    ```ObjC
    [self thIn:3 do:^(id obj) { 
        NSLog(@"The passed in object is the same as self. It's weakly held: %@", obj");
    }];
    ```

3. Building on these, `THInWeakTimer` is a lightweight timer. It has two methods. `-invalidate` specifically cancels the timer. The timer is also implicitly cancelled if the `THInWeakTimer` is deallocated.

    ```ObjC
    @interface THInWeakTimer : NSObject
    - (id)initWithDelay:(NSTimeInterval)delay do:(void (^)(void))block;
    - (void)invalidate;
    @end
    ```
    
In the first two cases, the target object is weakly held, so if it is released before the interval is up, the queued message/block will never be sent/invoked. Why? This is what made sense for my initial use case, and I still haven't found a case where I don't like the behaviour.

## How to use it

I've packaged this as a static library, you should be able to use it as detailed [in this blog post](http://www.blog.montgomerie.net/easy-xcode-static-library-subprojects-and-submodules). It's only a couple of files though, so I won't tell anyone if you just copy them into your project instead.

