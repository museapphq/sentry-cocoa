import XCTest

class SentryFrameInAppLogicTests: XCTestCase {
    
    private class Fixture {
        
        func getSut(inAppIncludes: [String] = [], inAppExcludes: [String] = [] ) -> SentryFrameInAppLogic {
            
            return SentryFrameInAppLogic(
                inAppIncludes: inAppIncludes,
                inAppExcludes: inAppExcludes
            )
        }
    }
    
    private let fixture = Fixture()
    
    func testNotInApp() {
        XCTAssertFalse(fixture.getSut().is(inApp: "a/Bundle/Application/a"))
        XCTAssertFalse(fixture.getSut().is(inApp: "a.app/"))
    }
    
    func testXcodeLibraries() {
        XCTAssertFalse(fixture.getSut().is(inApp: "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore"))
        
        // If someone has multiple Xcode installations
        XCTAssertFalse(fixture.getSut().is(inApp: "/Applications/Xcode 11.app/Contents/"))
        
        // If someone installed Xcode in a different location that Applications
        XCTAssertFalse(fixture.getSut().is(inApp: "/Users/sentry/Downloads/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore"))
    }
    
    func testInAppInclude() {
        XCTAssertTrue(
            fixture.getSut(inAppIncludes: ["PrivateFrameworks", "UIKitCore"])
                .is(inApp: "/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore")
        )
        
        XCTAssertFalse(fixture.getSut(inAppIncludes: ["/System", "UIKitCore"]).is(inApp: "/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore/"))
    }
    
    func testInAppExclude() {
        XCTAssertFalse(
            fixture.getSut(inAppExcludes: ["iOS-Swift"])
                .is(inApp: "/private/var/containers/Bundle/Application/D987FC7A-629E-41DD-A043-5097EB29E2F4/iOS-Swift.app/iOS-Swift")
        )
        
        XCTAssertFalse(
            fixture.getSut(inAppExcludes: ["iOS-Swift.app", "iOS-Swif"])
                .is(inApp: "/private/var/containers/Bundle/Application/D987FC7A-629E-41DD-A043-5097EB29E2F4/iOS-Swift.app/iOS-Swif")
        )
    }
    
    func testInAppIncludeTakesPrecedence() {
        XCTAssertTrue(
            fixture.getSut(inAppIncludes: ["libdyld.dylib"], inAppExcludes: ["libdyld.dylib"])
                .is(inApp: "/usr/lib/system/libdyld.dylib")
        )
        
        XCTAssertTrue(
            fixture.getSut(inAppIncludes: ["iOS-Swift"], inAppExcludes: ["iOS-Swift"])
                .is(inApp: "/private/var/containers/Bundle/Application/D987FC7A-629E-41DD-A043-5097EB29E2F4/iOS-Swift.app/iOS-Swift")
        )
        
        XCTAssertFalse(
            fixture.getSut(inAppIncludes: ["iOS-Swif"], inAppExcludes: ["iOS-Swift"])
                .is(inApp: "/private/var/containers/Bundle/Application/D987FC7A-629E-41DD-A043-5097EB29E2F4/iOS-Swift.app/iOS-Swift")
        )
    }
    
    func testFlutter() {
        let cfBundleExecutable = "Runner"
        
        let sut = fixture.getSut(inAppIncludes: [cfBundleExecutable])
        
        XCTAssertTrue(
            sut.is(inApp: "/private/var/containers/Bundle/Application/0024E236-61B3-48D4-A9D3-209E4A7B54F3/Runner.app/Runner")
        )
        
        XCTAssertFalse(
            sut.is(inApp: "/private/var/containers/Bundle/Application/0024E236-61B3-48D4-A9D3-209E4A7B54F3/Runner.app/Frameworks/Sentry.framework/Sentry")
        )
        
        XCTAssertFalse(
            sut.is(inApp: "/private/var/containers/Bundle/Application/0024E236-61B3-48D4-A9D3-209E4A7B54F3/Runner.app/Frameworks/Flutter.framework/Flutter")
        )
        
        XCTAssertFalse(
            sut.is(inApp: "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation")
        )
        
        XCTAssertFalse(
            sut.is(inApp: "/usr/lib/system/libdyld.dylib")
        )
    }
    
    func testiOSOnSimulator() {
        let cfBundleExecutable = "iOS-Swift"
        
        let sut = fixture.getSut(inAppIncludes: [cfBundleExecutable])
        
        XCTAssertTrue(
            sut.is(inApp: "/Users/sentry/Library/Developer/CoreSimulator/Devices/07184D2C-C93E-4993-8DC2-3677D4723CF5/data/Containers/Bundle/Application/407236BC-9C6F-4EDD-B20C-CA0F0AA36068/iOS-Swift.app/iOS-Swift"    )
        )
        
        XCTAssertFalse(
            sut.is(inApp: "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation")
        )
        
        XCTAssertFalse(
            sut.is(inApp: "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore")
        )
        
        XCTAssertFalse(
            sut.is(inApp: "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/AccessibilityBundles/UIKit.axbundle/UIKit")
        )
        
        XCTAssertFalse(
            sut.is(inApp: "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices")
        )
    }
    
    func testmacOS() {
        let cfBundleExecutable = "macOS-Swift"
        
        let sut = fixture.getSut(inAppIncludes: [cfBundleExecutable])
        
        XCTAssertTrue(
            sut.is(inApp: "/Users/sentry/Library/Developer/Xcode/DerivedData/Sentry-gcimrafeikdpcwaanncxmwrieqhi/Build/Products/Debug/macOS-Swift.app/Contents/MacOS/macOS-Swift"
            )
        )
        
        XCTAssertFalse(
            sut.is(inApp: "/System/Library/Frameworks/AppKit.framework/Versions/C/AppKit"
            )
        )
        
        XCTAssertFalse(
            sut.is(inApp: "/Users/sentry/Library/Developer/Xcode/DerivedData/Sentry-gcimrafeikdpcwaanncxmwrieqhi/Build/Products/Debug/macOS-Swift.app/Contents/Frameworks/Sentry.framework/Versions/A/Sentry"
            )
        )
    }
}
