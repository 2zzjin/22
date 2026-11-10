#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static void (*orig_setCSF)(id, SEL, CGFloat);

static void hooked_setCSF(id self, SEL _cmd, CGFloat scale) {
    if ([NSStringFromClass([self class]) isEqualToString:@"GLView"]) {
        scale = UIScreen.mainScreen.nativeScale;
    }
    orig_setCSF(self, _cmd, scale);
}

__attribute__((constructor)) static void resfix_init(void) {
    Method m = class_getInstanceMethod([UIView class], @selector(setContentScaleFactor:));
    if (!m) return;
    orig_setCSF = (void (*)(id, SEL, CGFloat))method_getImplementation(m);
    method_setImplementation(m, (IMP)hooked_setCSF);
}
