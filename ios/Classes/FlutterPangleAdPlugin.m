#import "FlutterPangleAdPlugin.h"
#if __has_include(<flutter_pangle_ad/flutter_pangle_ad-Swift.h>)
#import <flutter_pangle_ad/flutter_pangle_ad-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_pangle_ad-Swift.h"
#endif

@implementation FlutterPangleAdPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPangleAdPlugin registerWithRegistrar:registrar];
}
@end
