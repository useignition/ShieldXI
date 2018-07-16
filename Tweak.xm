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

%hook SBApplicationIcon
- (id)initWithApplication:(id)arg1 {
	self = %orig;
	return self;
}
%end

%hook SBUIController

-(void)activateApplication:(id)arg1 fromIcon:(id)arg2 location:(long long)arg3 activationSettings:(id)arg4 actions:(id)arg5 {
	SBApplication* app = arg1;
	NSString *bundleID = [app bundleIdentifier];
	NSString *dispName = [app displayName];

	UIViewController * controller = [[UIApplication sharedApplication] keyWindow].rootViewController;
	while (controller.presentedViewController) {
	    controller = controller.presentedViewController;
	}
	dismissedApp = bundleID;
	NSLog(@"%@", dispName);
	if (isTouchIDAvailable()) {
		LAContext *context = [[LAContext alloc] init];
		context.localizedFallbackTitle = @"";

		NSError *error = nil;
		if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
		    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"" reply:^(BOOL success, NSError *error) {
            	dispatch_async(dispatch_get_main_queue(), ^{
			      	if (error) {
			      		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
						NSString *title = @"ShieldXI";
						NSString *message = [NSString stringWithFormat:@"There was a problem verifying your identity."];
						
						UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
					    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
					    	// Extra Stuff?
					   	}];

					    [alert addAction:okButton];

						[controller presentViewController:alert animated:YES completion:nil];   
			        }

			  		if (success) {
			  			%orig();
					} else {
			    		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
						NSString *title = @"ShieldXI";
						NSString *message = [NSString stringWithFormat:@"You are not the device owner"];
						
						UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
					    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
					    	// Extra Stuff?
					   	}];
					    [alert addAction:okButton];

						[controller presentViewController:alert animated:YES completion:nil];   
					}
				});
			}];
		   } else {
		    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			NSString *title = @"ShieldXI";
			NSString *message = [NSString stringWithFormat:@"Your device cannot authenticate using TouchID."];
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
		    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		    	// Extra Stuff?
		   	}];
		    [alert addAction:okButton];
			[controller presentViewController:alert animated:YES completion:nil];   
		}
	} else {
			NSString *title = @"ShieldXI";
			NSString *message = [NSString stringWithFormat:@"Sorry, but Touch ID nor FaceID are available on your device. DM us on @useignition as we would like to know how you got this running on your device!"];
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		        %orig;
			}];
		    [alert addAction:okButton];
			[controller presentViewController:alert animated:YES completion:nil];   
	}
}
%end