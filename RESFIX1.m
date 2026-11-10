#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// 在原生分辨率的基础上再乘多少倍。2.0 = 再提高一倍,1.5 = 折中。
#define MULT 0.3

static void (*orig_setCSF)(id, SEL, CGFloat);

static void hooked_setCSF(id self, SEL _cmd, CGFloat scale) {
    if ([NSStringFromClass([self class]) isEqualToString:@"GLView"]) {
        scale = UIScreen.mainScreen.nativeScale * MULT;
    }
    orig_setCSF(self, _cmd, scale);
}

__attribute__((constructor)) static void resfix_init(void) {
    Method m = class_getInstanceMethod([UIView class], @selector(setContentScaleFactor:));
    if (!m) return;
    orig_setCSF = (void (*)(id, SEL, CGFloat))method_getImplementation(m);
    method_setImplementation(m, (IMP)hooked_setCSF);
}
