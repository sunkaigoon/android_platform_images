#import "AndroidPlatformImagesPlugin.h"
#if __has_include(<android_platform_images/android_platform_images-Swift.h>)
#import <android_platform_images/android_platform_images-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "android_platform_images-Swift.h"
#endif

@implementation AndroidPlatformImagesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAndroidPlatformImagesPlugin registerWithRegistrar:registrar];
}
@end
