//
//  NSTimer+TCHelper.m
//  SudiyiClient
//
//  Created by cdk on 15/5/9.
//  Copyright (c) 2015年 Sudiyi. All rights reserved.
//

#import "NSTimer+TCHelper.h"
#import <objc/runtime.h>

#if ! __has_feature(objc_arc)
#error this file is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif


static char const kIndexKey;
static char const kExecuteCountKey;
static char const kExecuteBlockKey;
static char const kCompleteBlockKey;

@implementation NSTimer (TCHelper)

@dynamic index;
@dynamic executeCount;
@dynamic executeBlock;
@dynamic completeBlock;


#pragma mark - getter / setter

- (NSUInteger)index
{
    NSNumber *value = (NSNumber *)objc_getAssociatedObject(self, &kIndexKey);
    return nil != value ? value.unsignedIntegerValue : 0;
}

- (void)setIndex:(NSUInteger)index
{
    objc_setAssociatedObject(self, &kIndexKey, @(index), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)executeCount
{
    return [(NSNumber *)objc_getAssociatedObject(self, &kExecuteCountKey) unsignedIntegerValue];
}

- (void)setExecuteCount:(NSUInteger)executeCount
{
    objc_setAssociatedObject(self, &kExecuteCountKey, @(executeCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(NSTimer *timer))executeBlock
{
    return objc_getAssociatedObject(self, &kExecuteBlockKey);
}

- (void)setExecuteBlock:(void (^)(NSTimer *timer))executeBlock
{
    objc_setAssociatedObject(self, &kExecuteBlockKey, executeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSTimer *timer))completeBlock
{
    return objc_getAssociatedObject(self, &kCompleteBlockKey);
}

- (void)setCompleteBlock:(void (^)(NSTimer *timer))completeBlock
{
    objc_setAssociatedObject(self, &kCompleteBlockKey, completeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


#pragma mark -

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                  executeBlock:(void (^)(NSTimer *timer))executeBlock
                                 completeBlock:(void (^)(NSTimer *timer))completeBlock
                                  executeCount:(NSUInteger)executeCount
{
    NSTimer *timer = [self scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(tcExecuteBlock:) userInfo:nil repeats:executeCount != 1];
    timer.executeCount = executeCount;
    timer.executeBlock = executeBlock;
    timer.completeBlock = completeBlock;
    
    return timer;
}

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval
                         executeBlock:(void (^)(NSTimer *timer))executeBlock
                        completeBlock:(void (^)(NSTimer *timer))completeBlock
                         executeCount:(NSUInteger)executeCount
{
    NSTimer *timer = [self timerWithTimeInterval:timeInterval target:self selector:@selector(tcExecuteBlock:) userInfo:nil repeats:executeCount != 1];
    timer.executeCount = executeCount;
    timer.executeBlock = executeBlock;
    timer.completeBlock = completeBlock;
    
    return timer;
}

+ (void)tcExecuteBlock:(NSTimer *)timer;
{
    timer.index = timer.index + 1;
    
    if (nil != timer.executeBlock) {
        timer.executeBlock(timer);
    }
    
    NSUInteger executeCount = timer.executeCount;
    
    if (executeCount > 0 && timer.index >= executeCount) {
        if (nil != timer.completeBlock) {
            timer.completeBlock(timer);
        }
        
        [timer tc_invalidate];
    }
}

- (void)tc_invalidate
{
    self.completeBlock = nil;
    self.executeBlock = nil;
    [self invalidate];
}

@end
