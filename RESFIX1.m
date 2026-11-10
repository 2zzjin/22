#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define MULT 2.0

static int gCalls = 0;
static CGFloat gAsked = 0, gSet = 0;

static void (*orig_setCSF)(id, SEL, CGFloat);
static void hooked_setCSF(id self, SEL _cmd, CGFloat scale) {
    if ([NSStringFromClass([self class]) isEqualToString:@"GLView"]) {
        gCalls++;
        gAsked = scale;
        scale = UIScreen.mainScreen.nativeScale * MULT;
        gSet = scale;
    }
    orig_setCSF(self, _cmd, scale);
}

static void showInfo(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
        UIWindow *win = nil;
        for (UIWindow *x in UIApplication.sharedApplication.windows) {
            if (x.isKeyWindow) win = x;
        }
        if (!win) win = UIApplication.sharedApplication.windows.firstObject;
        NSString *msg = [NSString stringWithFormat:
            @"ResFix loaded\nGLView calls %d\nasked %.2f -> set %.2f\nnative %.2f",
            gCalls, gAsked, gSet, UIScreen.mainScreen.nativeScale];
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, 360, 120)];
        l.numberOfLines = 0;
        l.text = msg;
        l.textColor = UIColor.whiteColor;
        l.backgroundColor = [UIColor colorWithRed:0.8 green:0 blue:0 alpha:0.9];
        l.userInteractionEnabled = NO;
        [win addSubview:l];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{ [l removeFromSuperview]; });
    });
}

__attribute__((constructor)) static void resfix_init(void) {
    Method m = class_getInstanceMethod([UIView class], @selector(setContentScaleFactor:));
    if (m) {
        orig_setCSF = (void (*)(id, SEL, CGFloat))method_getImplementation(m);
        method_setImplementation(m, (IMP)hooked_setCSF);
    }
    showInfo();
}
