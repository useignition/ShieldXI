#import <notify.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#include <dlfcn.h>

#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import<SpringBoard/SBApplicationController.h>
#import <objc/runtime.h>
#import <AudioToolbox/AudioServices.h>
#import <LocalAuthentication/LocalAuthentication.h>

// #import<SpringBoard/SBAlert.h>

@protocol SBUIBiometricEventMonitorDelegate
@required
-(void)biometricEventMonitor:(id)monitor handleBiometricEvent:(unsigned)event;
@end

@interface SBUIBiometricEventMonitor : NSObject
- (void)addObserver:(id)arg1;
- (void)removeObserver:(id)arg1;
- (void)_startMatching;
- (void)_setMatchingEnabled:(BOOL)arg1;
- (BOOL)isMatchingEnabled;
@end

@interface BiometricKit : NSObject
+ (id)manager;
@end

#define TouchIDFingerDown  1
#define TouchIDFingerUp    0
#define TouchIDFingerHeld  2
#define TouchIDMatched     3
#define TouchIDMaybeMatched 4
#define TouchIDNotMatched  9

@interface BTTouchIDController : NSObject <SBUIBiometricEventMonitorDelegate> {
	BOOL isMonitoring;
	BOOL previousMatchingSetting;
}
@property (nonatomic, strong) NSString* idToOpen;
+(id)sharedInstance;
-(void)startMonitoring;
-(void)stopMonitoring;
@end

@interface SBApplicationIcon : NSObject
- (void)launchFromLocation:(int)location;
- (id)displayName;
- (id)application;
-(id)applicationBundleID;
@end

@interface SBApplication : NSObject
- (id)bundleIdentifier;
- (id)initWithBundleIdentifier:(id)arg1 webClip:(id)arg2 path:(id)arg3 bundle:(id)arg4 infoDictionary:(id)arg5 isSystemApplication:(_Bool)arg6 signerIdentity:(id)arg7 provisioningProfileValidated:(_Bool)arg8 entitlements:(id)arg9;
- (id)displayName;
@end

@interface UIApplication (ShieldXI)
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
-(void)_handleMenuButtonEvent;
- (void)_giveUpOnMenuDoubleTap;
- (void)_menuButtonDown:(id)arg1;
- (void)menuButtonDown:(id)arg1;
- (BOOL)clickedMenuButton;
- (BOOL)handleMenuButtonDownEvent;
- (void)handleHomeButtonTap;
- (void)_giveUpOnMenuDoubleTap;
@end

@interface SBUIController : NSObject
+ (id)sharedInstance;
- (void)getRidOfAppSwitcher;
- (id)displayName;
- (id)application;
-(id)applicationBundleID;
// SBHomeScreenWindow* _window;
// UIView* _contentView;
-(id)window;
-(id)contentView;
@end

static NSString* dismissedApp;

void dismissToApp() {
	NSLog(@"ShieldXI Tweak::dissmissToApp()");
	[[UIApplication sharedApplication] launchApplicationWithIdentifier:dismissedApp suspended:NO];
	
}

BOOL isTouchIDAvailable() {
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;

    if (![myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        NSLog(@"%@", [authError localizedDescription]);
        return NO;
    }
    return YES;
}

void touchUnlock() {
	if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		// [handler.passcodeView validPassEntered];
		// [handler removePasscodeView];
		BTTouchIDController* controller = [%c(BTTouchIDController) sharedInstance];
		[[UIApplication sharedApplication] launchApplicationWithIdentifier:controller.idToOpen suspended:NO];
		[controller stopMonitoring];
	}
}

void touchFailed() {
	// [handler.passcodeView resetFailedPass];
}

@interface UIApplication (ShieldXIPrefs)
-(SBApplication*)_accessibilityFrontMostApplication;
@end

@implementation BTTouchIDController

+(id)sharedInstance {
	// Setup instance for current class once
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});
	// Provide instance
	return sharedInstance;
}

-(void)biometricEventMonitor:(id)monitor handleBiometricEvent:(unsigned)event {
	switch(event) {
		case TouchIDFingerDown:
			NSLog(@"[ShieldXI] Touched Finger Down");
			break;
		case TouchIDFingerUp:
			NSLog(@"[ShieldXI] Touched Finger Up");
			break;
		case TouchIDFingerHeld:
			NSLog(@"[ShieldXI] Touched Finger Held");
			break;
		case TouchIDMatched:
			NSLog(@"[ShieldXI] Touched Finger MATCHED :DDDDDDD");
			//If running in SpringBoard
			if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
				if ([[[UIApplication sharedApplication] _accessibilityFrontMostApplication].bundleIdentifier isEqualToString:@"com.apple.Preferences"]) {
					//in preferences :p
					NSLog(@"[ShieldXI] In Preferences");
					// notify_post("fun.ignition.shieldxi.prefstouchunlock");
				}
				else {
					NSString* openApp = [[UIApplication sharedApplication] _accessibilityFrontMostApplication].bundleIdentifier;
					NSLog(@"[ShieldXI] actually open app is %@", openApp);
					//are we in SpringBoard NOW?
					// notify_post("fun.ignition.shieldxi.touchunlock");
					dismissToApp();
				}
			}
			//else we're in preferences
			else {
				NSLog(@"[ShieldXI] In preferences, sending prefs notification");
				// notify_post("fun.ignition.shieldxi.prefstouchunlock");
			}
			[self stopMonitoring];
			break;
		case TouchIDNotMatched:
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			NSLog(@"[ShieldXI] Touched Finger NOT MATCHED DDDDDDD:");
			break;
		case 10:
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			NSLog(@"[ShieldXI] Touched Finger NOT MATCHED DDDDDDD:");
			break;
		default:
			//log(@"Touched Finger Other Event"); // Unneeded and annoying
			break;
	}
}

-(void)startMonitoring {
	// If already monitoring, don't start again
	if(isMonitoring) {
		return;
	}
	isMonitoring = YES;

	// Get current monitor instance so observer can be added
	SBUIBiometricEventMonitor* monitor = [[objc_getClass("BiometricKit") manager] delegate];
	// Save current device matching state
	previousMatchingSetting = [monitor isMatchingEnabled];

	// Begin listening :D
	[monitor addObserver:self];
	[monitor _setMatchingEnabled:YES];
	[monitor _startMatching];

	NSLog(@"[ShieldXI] Started monitoring");
}

-(void)stopMonitoring {
	// If already stopped, don't stop again
	if(!isMonitoring) {
		return;
	}
	isMonitoring = NO;

	// Get current monitor instance so observer can be removed
	SBUIBiometricEventMonitor* monitor = [[objc_getClass("BiometricKit") manager] delegate];
	
	// Stop listening
	[monitor removeObserver:self];
	[monitor _setMatchingEnabled:previousMatchingSetting];

	NSLog(@"[ShieldXI] Stopped Monitoring");
}

@end

%hook SBApplicationIcon
- (id)initWithApplication:(id)arg1 {
	self = %orig;
	return self;
}
// - (void)launchFromLocation:(int)location {
// 	// DebugLog0;
	
// 	SBApplication* app = (SBApplication *)[self application];
// 	NSString *bundleID = [app bundleIdentifier];
// 	NSString *dispName = [self displayName];

// 	UIViewController * controller = [UIApplication sharedApplication].keyWindow.rootViewController;
// 	while (controller.presentedViewController) {
// 	    controller = controller.presentedViewController;
// 	}

// 	NSString *title = @"ShieldXI";
// 	NSString *message = [NSString stringWithFormat:@"Do you want to open %@, with bundle id %@", dispName, bundleID];
	
// 	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	
// 	[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];

// 	[controller presentViewController:alert animated:YES completion:nil];   
// 	// DebugLog(@"app id: %@", bundleID);
	
// 	// currentlyOpening = bundleID;
// 	// dispName = [self displayName];
	
// 	// DebugLog(@"oncePerRespring is %@", oncePerRespring);
// 	// if ([oncePerRespring containsObject:bundleID]) {
// 	// 	DebugLog(@"App was only locked once per respring, now unlocked");
// 	// 	%orig;
// 	// 	return;
// 	// }

// 	// if ([lockedApps containsObject:bundleID] && ![oncePerRespring containsObject:bundleID]) {
// 	// 	if (!shouldLaunch) {
// 	// 		DebugLog(@"showing pass view...");
// 	// 		[handler showPasscodeViewWithBundleID:bundleID andDisplayName:dispName];
// 	// 	}
// 	// 	else {
// 	// 		%orig;
// 	// 		shouldLaunch = NO;
// 	// 		[handler.passcodeView reset];
// 	// 	}
// 	// }
// 	// else {
// 	// 	%orig;
// 	// 	shouldLaunch = NO;
// 	// 	[handler.passcodeView reset];
// 	// }
// }

// - (id)generateIconImage:(int)arg1 {
// 	// DebugLog0;
	
// 	id image = %orig;
	
// 	//This works really, really bad. Commenting out for now
// 	/*
// 	if (lockedApps && [lockedApps containsObject:[self applicationBundleID]]) {
// 		[self shade];
// 	} else {
// 		DebugLog(@"no locked apps.");
// 	}
// 	*/

// 	return image;
// }

// %new
// - (void)shade {
// 	// DebugLog(@"shade()");
	
// 	SBIconView *iconView = [[%c(SBIconViewMap) homescreenMap] iconViewForIcon:self];
// 	// DebugLog(@"> my iconView is %@", iconView);
	
// 	//int blurStyle = kUIBackdropViewSettingsPasscodePaddle;
// 	int blurStyle = kUIBackdropViewSettingsDark;
	
// 	_UIBackdropView *shade = [[_UIBackdropView alloc] initWithFrame:CGRectZero
// 											autosizesToFitSuperview:YES
// 														   settings:[_UIBackdropViewSettings settingsForPrivateStyle:blurStyle]];
// 	[shade setBlurQuality:@"default"];
	
// 	CGRect frame = iconView.frame;
// 	shade.frame = frame;

// 	shade.clipsToBounds = YES;
	
// 	// DebugLog(@"> created shade: %@", shade);
// 	[iconView insertSubview:shade atIndex:0];
// }
// %end
%end

%hook SBUIController

// -(void)launchIcon:(id)arg1 fromLocation:(long long)arg2 context:(id)arg3 activationSettings:(id)arg4 actions:(id)arg5 {
// 	SBApplication* app = arg1;
// 	NSString *bundleID = [app bundleIdentifier];
// 	NSString *dispName = [app displayName];

// 	UIViewController * controller = [UIApplication sharedApplication].keyWindow.rootViewController;
// 	while (controller.presentedViewController) {
// 	    controller = controller.presentedViewController;
// 	}

// 	NSString *title = @"ShieldXI";
// 	NSString *message = [NSString stringWithFormat:@"Do you want to open %@, with bundle id %@", dispName, bundleID];
	
// 	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	
// 	UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"I own it." style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
// 		//Handle your yes please button action here
//         %orig;
// 	}];

//     UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"I don't" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//     	//Handle no, thanks button
//    	}];

//     //Add your buttons to alert controller

//     [alert addAction:yesButton];
//     [alert addAction:noButton];

// 	[controller presentViewController:alert animated:YES completion:nil];   
// }


-(void)activateApplication:(id)arg1 fromIcon:(id)arg2 location:(long long)arg3 activationSettings:(id)arg4 actions:(id)arg5 {
	// SBApplication* app = arg1;
	// NSString *bundleID = [app bundleIdentifier];
	// NSString *dispName = [app displayName];
	SBApplication* app = arg1;
	NSString *bundleID = [app bundleIdentifier];
	NSString *dispName = [app displayName];

	UIViewController * controller = [[UIApplication sharedApplication] keyWindow].rootViewController;
	while (controller.presentedViewController) {
	    controller = controller.presentedViewController;
	}
	dismissedApp = bundleID;
	// UIWindow *windowNew = [[UIApplication sharedApplication] keyWindow];
	NSLog(@"%@", dispName);
	if (isTouchIDAvailable()) {
		BTTouchIDController* sharedBT = [%c(BTTouchIDController) sharedInstance];
		[sharedBT startMonitoring];
		sharedBT.idToOpen = bundleID;
		NSString *title = @"ShieldXI";
		NSString *message = [NSString stringWithFormat:@"Do you want to open %@, with the bundle ID %@?", dispName, bundleID];
		
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			BTTouchIDController* sharedBT = [%c(BTTouchIDController) sharedInstance];
			[sharedBT startMonitoring];
			sharedBT.idToOpen = bundleID;
			// touchUnlock();
			notify_post("fun.ignition.shieldxi.touchunlock");
			// - (void)_startMatching;
// - (void)_setMatchingEnabled:(BOOL)arg1;
// [SBUIBiometricEventMonitor setMatchingEnabled:YES];

			// notify_post("fun.ignition.shieldxi.touchunlock");
	        // %orig;
		}];

	    UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
	    	//Handle no, thanks button
	    	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	    	if (isTouchIDAvailable()) [[%c(BTTouchIDController) sharedInstance] stopMonitoring];
	   	}];

	    //Add your buttons to alert controller

	    [alert addAction:yesButton];
	    [alert addAction:noButton];

		[controller presentViewController:alert animated:YES completion:nil];   
	} else {
			NSString *title = @"ShieldXI";
			NSString *message = [NSString stringWithFormat:@"Sorry, but Touch ID nor FaceID are available on your device. DM us on @useignition as we would like to know how you got this running on your device!"];
			
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
			
			UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
				//Handle your yes please button action here
		        %orig;
			}];

		    //Add your buttons to alert controller

		    [alert addAction:yesButton];

			[controller presentViewController:alert animated:YES completion:nil];   
	}
}
%end

%ctor {
	@autoreleasepool {
		NSLog(@"ShieldXI init.");

			// %init(Main);

			NSLog(@"[ShieldXI] Running on iOS 8 or Above");
			%init;
			NSLog(@"ShieldXI is enabled");
			
			// handler = [[ShieldXIPassShower alloc] init];
			// timeLockedApps = [[NSMutableArray alloc] init];
			// oncePerRespring = [[NSMutableArray alloc] init];
			// openApps = [[NSMutableArray alloc] init];
			
			// lockedApps = [[NSMutableArray alloc] init];
			
			// CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
			// 								NULL,
			// 								(CFNotificationCallback)loadPreferences,
			// 								CFSTR("fun.ignition.shieldxi/settingschanged"),
			// 								NULL,
			// 								CFNotificationSuspensionBehaviorDeliverImmediately);
			
			// CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
			// 								NULL,
			// 								(CFNotificationCallback)dismissToApp,
			// 								CFSTR("fun.ignition.shieldxi.multitaskEscape"),
			// 								NULL,
			// 								CFNotificationSuspensionBehaviorDeliverImmediately);

			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
											NULL,
											(CFNotificationCallback)touchUnlock,
											CFSTR("fun.ignition.shieldxi.touchunlock"),
											NULL,
											CFNotificationSuspensionBehaviorDeliverImmediately);
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
											NULL,
											(CFNotificationCallback)touchFailed,
											CFSTR("fun.ignition.shieldxi.touchfailed"),
											NULL,
											CFNotificationSuspensionBehaviorDeliverImmediately);

			
			// dismissToApp();
			// CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
			// 								NULL,
			// 								(CFNotificationCallback)touchUnlock,
			// 								CFSTR("fun.ignition.shieldxi.touchunlock"),
			// 								NULL,
			// 								CFNotificationSuspensionBehaviorDeliverImmediately);
			// CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
			// 								NULL,
			// 								(CFNotificationCallback)touchFailed,
			// 								CFSTR("fun.ignition.shieldxi.touchfailed"),
			// 								NULL,
			// 								CFNotificationSuspensionBehaviorDeliverImmediately);

			dismissToApp();
	}
}

