//
//  GVRVideoView+Hacking.h.m
//  VideoWidgetDemo
//
//  Created by Martin Lloyd on 02/08/2016.
//
//

#import <objc/runtime.h>
#import <objc/message.h>

#import <GoogleVR/GVRVideoView.h>

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void Swizz(Class c, SEL orig, SEL replace)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, replace);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, replace, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }
    else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
NSArray *RTVClassDescendantsOfClass(Class parentClass)
{
    Class *classes = NULL;
    int numClasses = objc_getClassList(NULL, 0);;
    
    if(numClasses == 0) return @[];
    
    classes = (Class *)malloc(sizeof(Class) * numClasses);
    if(classes == NULL) return @[];
    
    objc_getClassList(classes, numClasses);
    
    NSMutableArray *descendentClasses = [NSMutableArray array];
    
    for(NSInteger i = 0; i < numClasses; i++) {
        Class superClass = classes[i];
        
        do {
            superClass = class_getSuperclass(superClass);
        }
        while(superClass != NULL && superClass != parentClass);
        
        if(superClass == NULL) continue;
        
        [descendentClasses addObject:classes[i]];
    }
    free(classes);
    
    return descendentClasses;
}

////////////////////////////////////////////////////////////////////////////////
/*
    po [[UIApplication sharedApplication] windows]
    po [GOOOverlayWindow performSelector:@selector(_methodDescription)] 
 */
////////////////////////////////////////////////////////////////////////////////
@implementation GVRVideoView (Hacking)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Swizz([self class], @selector(loadFromUrl:), @selector(xxx_loadFromUrl:));
        
        NSLog(@"%@", RTVClassDescendantsOfClass(NSClassFromString(@"UIWindow")));
        NSLog(@"%@", [UIApplication sharedApplication].windows);
    });
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
- (void)xxx_loadFromUrl:(NSURL *)URL
{
    NSLog(@"hello");
    [self xxx_loadFromUrl:URL];
}

@end
