//
//  UIView+StatusBarView.m
//  StatusBarView
//
//  Created by hubo on 15/8/7.
//  Copyright (c) 2015年 netease. All rights reserved.
//

#import "UIView+StatusBarView.h"
#import <objc/runtime.h>

@interface StatusBarAccessor : NSObject
+ (StatusBarAccessor *)sharedInstance;
@property (nonatomic, strong) UIView *sysStatusView;
@end

@implementation StatusBarAccessor

static StatusBarAccessor *_statusBarAccessorInstance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _statusBarAccessorInstance = [[StatusBarAccessor alloc] init];
    });
    
    return _statusBarAccessorInstance;
}

- (id)init {
    self = [super init];
    if (self != nil) {
    }
    return self;
}

- (UIView *)statuBarView {
    if (_sysStatusView == nil) {
        NSString *key = [[NSString alloc] initWithData:[NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9] encoding:NSASCIIStringEncoding];
        id object = [UIApplication sharedApplication];
        if ([object respondsToSelector:NSSelectorFromString(key)]) {
            _sysStatusView = [object valueForKey:key];
        }
    }
    
    return _sysStatusView;
}
@end


@implementation UIView (StatusBarView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"UIStatusBar");
        [self swizzClass:cls
                selector:@selector(setFrame:)
                selector:@selector(customSetFrame:)];
        [self swizzClass:cls
                selector:NSSelectorFromString(@"dealloc")
                selector:@selector(customDealloc)];
    });
}

+ (void)swizzClass:(Class)c selector:(SEL)orig selector:(SEL)replace {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, replace);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, replace, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

+ (UIView *)sys_statusBarVIew {
    return [[StatusBarAccessor sharedInstance] statuBarView];
}

- (void)customSetFrame:(CGRect)frame {
    [StatusBarAccessor sharedInstance].sysStatusView = self;
    [self customSetFrame:frame];
}

- (void)customDealloc {
    _statusBarAccessorInstance = nil;
    [self customDealloc];
}
@end
