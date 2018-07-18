#import <notify.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#include <dlfcn.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>
#import <objc/runtime.h>
#import <AudioToolbox/AudioServices.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "SparkAppList.h"
#include "capture.h"
#import <sys/stat.h>

#define kSettingsPath	[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/fun.ignition.shieldxi.plist"]
#define guestMode YES


@interface SBMediaController
+(id)sharedInstance;
-(BOOL)isRingerMuted;
-(void)setRingerMuted:(BOOL)muted;
@end

@interface SBApplicationIcon : NSObject
- (void)launchFromLocation:(int)location;
- (id)displayName;
- (id)application;
-(id)applicationBundleID;
@end

@interface SBFolderIcon : NSObject
-(void)launchFromLocation:(long long)arg1 context:(id)arg2 activationSettings:(id)arg3 actions:(id)arg4;
@end

// @interface SBApplication : NSObject
// - (id)bundleIdentifier;
// - (id)initWithBundleIdentifier:(id)arg1 webClip:(id)arg2 path:(id)arg3 bundle:(id)arg4 infoDictionary:(id)arg5 isSystemApplication:(_Bool)arg6 signerIdentity:(id)arg7 provisioningProfileValidated:(_Bool)arg8 entitlements:(id)arg9;
// - (id)displayName;
// @end

@interface CAFilter : NSObject
+(instancetype)filterWithName:(NSString *)name;
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

@interface SBAppSwitcherController : UIViewController {
}
@property (copy) Class superclass; 
@property (copy,copy) NSString* description; 
@property (copy,copy) NSString* debugDescription; 
+(void)setPerformSochiMigrationTasksWhenLoaded:(_Bool)arg1;
+(_Bool)shouldProvideSnapshotIfPossible;
+(_Bool)shouldProvideHomeSnapshotIfPossible;
+(_Bool)_shouldUseSerialSnapshotQueue;
+(double)pageScale;
-(void)handleReachabilityModeDeactivated;
-(id)_peopleViewController;
-(void)handleVolumeIncrease;
-(void)handleVolumeDecrease;
-(_Bool)allowShowHide;
-(void)animatePresentationFromDisplayLayout:(id)arg1 withViews:(id)arg2 withCompletion:(id)arg3;
-(void)switcherWasPresented:(_Bool)arg1;
-(_Bool)workspaceShouldAbortLaunchingAppDueToSwitcher:(id)arg1 url:(id)arg2 actions:(id)arg3;
-(void)switcherWillBeDismissed:(_Bool)arg1;
-(void)switcherWasDismissed:(_Bool)arg1;
-(void)animateDismissalToDisplayLayout:(id)arg1 withCompletion:(id)arg2;
-(void)handleRevealNotificationCenterGesture:(id)arg1;
-(_Bool)_shouldRespondToReachability;
-(void)_performReachabilityTransactionForActivate:(_Bool)arg1 immediately:(_Bool)arg2;
-(void)_switcherServiceRemoved:(id)arg1;
-(void)_appActivationStateDidChange:(id)arg1;
-(void)_switcherRemoteAlertRemoved:(id)arg1;
-(void)_switcherRemoteAlertAdded:(id)arg1;
-(void)_continuityAppSuggestionChanged:(id)arg1;
-(void)_warmAppInfoForAppsInList;
-(void)_finishDeferredSochiMigrationTasks;
-(void)handleCancelReachabilityGesture:(id)arg1;
-(double)_switcherThumbnailVerticalPositionOffset;
-(CGRect)_nominalPageViewFrame;
-(void)setStartingDisplayLayout:(id)arg1;
-(void)setStartingViews:(id)arg1;
-(void)_cacheAppList;
-(void)_updatePageViewScale:(double)arg1 xTranslation:(double)arg2;
-(void)_temporarilyHostAppForQuitting:(id)arg1;
-(void)_layoutInOrientation:(long long)arg1;
-(void)_updateForAnimationFrame:(double)arg1 withAnchor:(id)arg2;
-(void)_bringIconViewToFront;
-(id)_transitionAnimationFactory;
-(_Bool)_inMode:(int)arg1;
-(void)_updateSnapshots;
-(void)_peopleWillAnimateOpacity;
-(void)_peopleDidAnimateOpacity;
-(id)_animationFactoryForIconAlphaTransition;
-(void)_accessAppListState:(id)arg1;
-(void)_setInteractionEnabled:(_Bool)arg1;
-(void)_unsimplifyStatusBarsAfterMotion;
-(void)_disableContextHostingForApp:(id)arg1;
-(void)_destroyAppListCache;
-(void)_askDelegateToDismissToDisplayLayout:(id)arg1 displayIDsToURLs:(id)arg2 displayIDsToActions:(id)arg3;
-(id)_generateCellViewForDisplayLayout:(id)arg1;
-(double)_scaleForFullscreenPageView;
-(void)_quitAppWithDisplayItem:(id)arg1;
-(void)_rebuildAppListCache;
-(id)pageForDisplayLayout:(id)arg1;
-(void)addContentViewForRemoteAlert:(id)arg1 toAlertViewCell:(id)arg2 animated:(_Bool)arg3;
-(id)_viewForService:(id)arg1;
-(id)_viewForRemoteAlert:(id)arg1 placeholder:(_Bool)arg2;
-(id)_viewForContinuityApp:(id)arg1;
-(id)_snapshotViewForDisplayItem:(id)arg1;
-(_Bool)_isBestAppSuggestionEligibleForSwitcher:(id)arg1;
-(id)_flattenedArrayOfDisplayItemsFromDisplayLayouts:(id)arg1;
-(id)_displayLayoutsFromDisplayLayouts:(id)arg1 byRemovingDisplayItems:(id)arg2;
-(void)_insertDisplayLayout:(id)arg1 atIndex:(unsigned long long)arg2 completion:(id)arg3;
-(void)_removeDisplayLayout:(id)arg1 completion:(id)arg2;
-(void)_updateSnapshotsForce:(_Bool)arg1;
-(unsigned long long)_totalLayoutsForWhichToKeepAroundSnapshots;
-(_Bool)_isSnapshotDisplayIdentifier:(id)arg1;
-(void)launchAppWithIdentifier:(id)arg1 url:(id)arg2 actions:(id)arg3;
-(void)_simplifyStatusBarsForMotion;
-(void)_insertRemoteAlertPlaceholder:(id)arg1 atIndex:(unsigned long long)arg2 completion:(id)arg3;
-(void)_removeRemoteAlertPlaceholder:(id)arg1 completion:(id)arg2;
-(void)_insertApp:(id)arg1 atIndex:(unsigned long long)arg2 completion:(id)arg3;
-(void)_animateReachabilityActivatedWithHandler:(id)arg1;
-(void)_animateReachabilityDeactivatedWithHandler:(id)arg1;
-(void)switcherIconScroller:(id)arg1 contentOffsetChanged:(double)arg2;
-(void)switcherIconScroller:(id)arg1 activate:(id)arg2;
-(_Bool)switcherIconScroller:(id)arg1 shouldHideIconForDisplayLayout:(id)arg2;
-(void)switcherIconScrollerBeganPanning:(id)arg1;
-(unsigned long long)switcherIconScroller:(id)arg1 settledIndexForNormalizedOffset:(int)arg2 andXVelocity:(double)arg3;
-(void)switcherIconScrollerDidEndScrolling:(id)arg1;
-(id)switcherScroller:(id)arg1 viewForDisplayLayout:(id)arg2;
-(_Bool)switcherScroller:(id)arg1 isDisplayItemRemovable:(id)arg2;
-(_Bool)switcherScrollerIsRelayoutBlocked:(id)arg1;
-(CGSize)switcherScrollerItemSize:(id)arg1 forOrientation:(long long)arg2;
-(double)switcherScrollerDistanceBetweenItemCenters:(id)arg1 forOrientation:(long long)arg2;
-(void)switcherScroller:(id)arg1 contentOffsetChanged:(double)arg2;
-(void)switcherScroller:(id)arg1 itemTapped:(int)arg2;
-(void)switcherScrollerBeganPanning:(id)arg1;
-(void)switcherScroller:(id)arg1 displayItemWantsToBeRemoved:(id)arg2;
-(_Bool)switcherScroller:(id)arg1 displayItemWantsToBeKeptInViewHierarchy:(id)arg2;
-(void)switcherScrollerDidEndScrolling:(id)arg1;
-(void)switcherScrollerBeganMoving:(id)arg1;
-(void)switcherScroller:(id)arg1 updatedPeakPageOffset:(double)arg2;
-(double)reachabilityOffsetForSwitcherScroller:(id)arg1;
-(void)appSwitcherContainer:(id)arg1 movedToWindow:(id)arg2;
-(void)peopleController:(id)arg1 wantsToContact:(id)arg2;
-(double)_frameScaleValueForAnimation;
-(void)_updatePageViewScale:(double)arg1;
-(void)_insertMultipleAppDisplayLayout:(id)arg1 atIndex:(unsigned long long)arg2 completion:(id)arg3;
-(void)cleanupRemoteAlertServices;
-(void)dealloc;
-(void)setDelegate:(id)arg1;
-(id)init;
-(_Bool)gestureRecognizerShouldBegin:(id)arg1;
-(_Bool)prefersStatusBarHidden;
-(long long)_windowInterfaceOrientation;
-(_Bool)shouldAutorotate;
-(unsigned long long)supportedInterfaceOrientations;
-(_Bool)wantsFullScreenLayout;
-(void)loadView;
-(_Bool)shouldAutomaticallyForwardRotationMethods;
-(void)willRotateToInterfaceOrientation:(long long)arg1 duration:(double)arg2;
-(void)willAnimateRotationToInterfaceOrientation:(long long)arg1 duration:(double)arg2;
-(void)didRotateFromInterfaceOrientation:(long long)arg1;
-(void)_getRotationContentSettings:(id)arg1;
-(void)_layout;
-(void)settings:(id)arg1 changedValueForKey:(id)arg2;
-(void)setLegibilitySettings:(id)arg1;
-(_Bool)isScrolling;
-(id)pageController;
-(void)handleReachabilityModeActivated;
-(void)forceDismissAnimated:(_Bool)arg1;
@end

@interface SBDisplayItem : NSObject {
	NSString* _uniqueStringRepresentation; 
	NSString* _type; 
	NSString* _displayIdentifier; 
}
@property (nonatomic,copy) NSString* type; 				//@synthesize type=_type - In the implementation block
@property (nonatomic,copy) NSString* displayIdentifier; 				//@synthesize displayIdentifier=_displayIdentifier - In the implementation block
+(id)displayItemWithType:(NSString*)arg1 displayIdentifier:(id)arg2;
-(id)initWithType:(NSString*)arg1 displayIdentifier:(id)arg2;
-(id)_calculateUniqueStringRepresentation;
-(id)plistRepresentation;
-(id)uniqueStringRepresentation;
-(id)initWithPlistRepresentation:(id)arg1;
-(void)dealloc;
-(_Bool)isEqual:(id)arg1;
-(unsigned long long)hash;
-(id)description;
@end

@interface SBDisplayLayout : NSObject {
	long long _layoutSize; 
	NSMutableArray* _displayItems; 
	NSString* _uniqueStringRepresentation; 
}
@property (nonatomic) long long layoutSize; 				//@synthesize layoutSize=_layoutSize - In the implementation block
@property (nonatomic, retain) NSArray* displayItems; 				//@synthesize displayItems=_displayItems - In the implementation block
+(id)displayLayoutWithLayoutSize:(long long)arg1 displayItems:(id)arg2;
+(id)homeScreenDisplayLayout;
+(id)fullScreenDisplayLayoutForApplication:(id)arg1;
+(id)displayLayoutWithPlistRepresentation:(id)arg1;
-(id)_calculateUniqueStringRepresentation;
-(id)plistRepresentation;
-(id)uniqueStringRepresentation;
-(id)displayLayoutByRemovingDisplayItems:(id)arg1;
-(id)displayLayoutByRemovingDisplayItem:(id)arg1;
-(id)initWithLayoutSize:(long long)arg1 displayItems:(id)arg2;
-(id)displayLayoutByAddingDisplayItem:(id)arg1 side:(long long)arg2 withLayout:(long long)arg3;
-(id)displayLayoutByReplacingDisplayItemOnSide:(long long)arg1 withDisplayItem:(id)arg2;
-(id)displayLayoutBySettingSize:(long long)arg1;
-(void)dealloc;
-(_Bool)isEqual:(id)arg1;
-(unsigned long long)hash;
-(id)description;
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

@interface SBIcon : NSObject
-(id)application;
@end

@interface SBIconView : UIView
@property (nonatomic,retain) SBIcon * icon;
-(void)setIconImageAlpha:(double)arg1;
-(void)setIconAccessoryAlpha:(double)arg1;
-(void)_applyIconImageAlpha:(double)arg1;
@end

@interface SBMainSwitcherViewController : UIViewController
-(void)_destroyAppListCache;
@end

@interface SBFluidSwitcherItemContainerHeaderView : UILabel {
  UILabel* _firstIconTitle;
}
@end

static NSString* dismissedApp;
static NSMutableDictionary* prefs;
static NSMutableArray* openApps;
static BOOL enabled;
static BOOL folders;
static BOOL intruderKey;
static BOOL hasCustomMessage;
static NSString *reason;
static NSString *customMessage;

void dismissToApp() {
	NSLog(@"ShieldXI Tweak::dissmissToApp()");
	[[UIApplication sharedApplication] launchApplicationWithIdentifier:dismissedApp suspended:NO];
	
}


//credits to Lucas Jackson aka neoneggplant https://github.com/neoneggplant/camshot/blob/master/main.mm && Jakeashacks https://github.com/jakeajames/CatchaThief/blob/master/Tweak.xm
void takepicture(BOOL isfront,char* filename) {

    BOOL isMuted = [[%c(SBMediaController) sharedInstance] isRingerMuted];
    if (!isMuted)  [[%c(SBMediaController) sharedInstance] setRingerMuted:true];

    capture *cam = [[capture alloc] init];
    [cam setupCaptureSession:isfront];
    [cam setfilename:[NSString stringWithFormat:@"%s" , filename]];
    [NSThread sleepForTimeInterval:0.2];

    __block BOOL done = NO;
    [cam captureWithBlock:^(UIImage *image)
     {done = YES;}];
    while (!done)
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    [cam release];

    if (!isMuted)  [[%c(SBMediaController) sharedInstance] setRingerMuted:false];
}

void loadPreferences() {
//static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	//[//preferences release];
	CFStringRef appID = CFSTR("fun.ignition.shieldxi");
	CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!keyList) {
		NSLog(@"[ShieldXI] There's been an error getting the key list!");
		return;
	}
	prefs = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
	if (!prefs) {
		NSLog(@"[ShieldXI] There's been an error getting the preferences dictionary!");
	}
	
	NSLog(@"Tweak::loadPreferences()");

	NSLog(@"[ShieldXI] settings updated, prefs is %@", prefs);

	//prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kSettingsPath] ?: [NSMutableDictionary dictionary];
	NSLog(@"read prefs from disk: %@", prefs);
	
	if (prefs[@"enabled"] && ![prefs[@"enabled"] boolValue]) {
		enabled = NO;
	} else {
		enabled = YES;
	}

	if (prefs[@"intruderKey"] && ![prefs[@"intruderKey"] boolValue]) {
		intruderKey = NO;
	} else {
		intruderKey = YES;
	}

	if (prefs[@"folders"] && ![prefs[@"folders"] boolValue]) {
		folders = NO;
	} else {
		folders = YES;
	}

	if (prefs[@"hasCustomMessage"] && ![prefs[@"hasCustomMessage"] boolValue]) {
		hasCustomMessage = NO;
	} else {
		hasCustomMessage = YES;
	}

	if (![prefs[@"customMessage"] isEqual: @""]) {
		customMessage = prefs[@"customMessage"];
	} else {
		customMessage = @"Are you the device owner?";
	}


	NSLog(@"setting for enabled:%d", enabled);
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

@interface SBHomeScreenViewController : UIViewController
@end

%hook SBHomeScreenViewController

- (void)viewWillLayoutSubviews{
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/fun.ignition.shieldxi.list"]){
        %orig;
    } else {
        %orig;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ShieldXI" message:@"Sorry, but it seems you are using an unofficial version of ShieldXI which can contain malware and may not always be up-to-date with the latest security patches. We recommend removing this version and reinstalling from BigBoss, it is a free tweak." preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];

        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }

}

%end

%hook SBFolderIcon
	-(void)launchFromLocation:(long long)arg1 context:(id)arg2 activationSettings:(id)arg3 actions:(id)arg4 {
		if (folders) {
			UIViewController * controller = [[UIApplication sharedApplication] keyWindow].rootViewController;
			while (controller.presentedViewController) {
			    controller = controller.presentedViewController;
			}
			if (isTouchIDAvailable()) {
				LAContext *context = [[LAContext alloc] init];
				context.localizedFallbackTitle = @"Greasy Fingers?\nEnter Password.";

				if (hasCustomMessage) {
					reason = customMessage;
				} else {
					reason = @"Are you the device owner?";
				}

				reason = @"Are you the device owner?";

				NSError *error = nil;
				if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
				    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError *error) {
			            	dispatch_async(dispatch_get_main_queue(), ^{
						      	if (error) {
						      		if (intruderKey) {
						      			if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/ShieldXI"]) {
						      			    mkdir("/var/mobile/ShieldXI", 0777);
						      			}
						      			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
						      			[formatter setDateFormat:@"dd.MM.YY:HH.mm.ss"];
						      			takepicture(true, (char*)[[NSString stringWithFormat:@"/var/mobile/ShieldXI/%@.png", [formatter stringFromDate:[NSDate date]]] UTF8String]);
						      		}
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
									if (intruderKey) {
										if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/ShieldXI"]) {
										    mkdir("/var/mobile/ShieldXI", 0777);
										}
										NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
										[formatter setDateFormat:@"dd.MM.YY:HH.mm.ss"];
										takepicture(true, (char*)[[NSString stringWithFormat:@"/var/mobile/ShieldXI/%@.png", [formatter stringFromDate:[NSDate date]]] UTF8String]);
									}
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
					NSString *message = [NSString stringWithFormat:@"Sorry, but Touch ID nor FaceID are available on your device right now. Please lock and unlock your device using your passcode."];
					UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
					UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
				        // %orig;
					}];
				    [alert addAction:okButton];
					[controller presentViewController:alert animated:YES completion:nil];   
			}
		} else {
			%orig;
		}
	}
%end

%hook SBApplicationIcon
- (id)initWithApplication:(id)arg1 {
	self = %orig;
	return self;
}
%end

%hook SBIconView
	
	- (void)layoutSubviews {
		%orig();
		if (guestMode) {
			SBIcon *ico = self.icon;
			SBApplication *app = ico.application;

			NSString *bundleID = [app bundleIdentifier];
			if ([SparkAppList doesIdentifier:@"fun.ignition.shieldxi" andKey:@"lockedApps" containBundleIdentifier:bundleID]) {
				// self.alpha = 0.3;
				[self setUserInteractionEnabled: NO];
				[self setIconImageAlpha: 0.3];
				[self setIconAccessoryAlpha: 0.3];
				[self _applyIconImageAlpha: 0.3];
			}
			// SBMainSwitcherViewController *appSwitcher;
			// SBMainSwitcherViewController *appSwitcher = MSHookIvar<SBMainSwitcherViewController *>(self, "_contentViewController");

			// [appSwitcher _destroyAppListCache];
		} else {

		}
	}

%end

%hook SBFluidSwitcherItemContainer

	- (void)layoutSubviews {
		%orig;
		UILabel *firstIconTitle = MSHookIvar<UILabel *>(self, "_firstIconTitle");
		[self addObserver:firstIconTitle forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
	}

	-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

	    if ([keyPath isEqualToString:@"text"]) {

	        // NSLog(@"Textfield changed - MAKE CHANGES HERE");
	        // NSLog(@"Name has changed");
	        SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
	        SBApplication *frontApp = (SBApplication *)[springBoard _accessibilityFrontMostApplication];
	        NSString *currentApp;
	        currentApp = [frontApp valueForKey:@"_bundleIdentifier"];
	        if([SparkAppList doesIdentifier:@"fun.ignition.shieldxi" andKey:@"lockedApps" containBundleIdentifier:currentApp]) {
	        	UIViewController * controller = [[UIApplication sharedApplication] keyWindow].rootViewController;
	        	while (controller.presentedViewController) {
	        	    controller = controller.presentedViewController;
	        	}
	        	if (isTouchIDAvailable()) {
	        		LAContext *context = [[LAContext alloc] init];
	        		context.localizedFallbackTitle = @"Greasy Fingers?\nEnter Password.";

	        		if (hasCustomMessage) {
	        			reason = customMessage;
	        		} else {
	        			reason = @"Are you the device owner?";
	        		}

	        		reason = @"Are you the device owner?";

	        		NSError *error = nil;
	        		if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
	        		    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError *error) {
	        	            	dispatch_async(dispatch_get_main_queue(), ^{
	        				      	if (error) {
	        				      		if (intruderKey) {
	        				      			if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/ShieldXI"]) {
	        				      			    mkdir("/var/mobile/ShieldXI", 0777);
	        				      			}
	        				      			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	        				      			[formatter setDateFormat:@"dd.MM.YY:HH.mm.ss"];
	        				      			takepicture(true, (char*)[[NSString stringWithFormat:@"/var/mobile/ShieldXI/%@.png", [formatter stringFromDate:[NSDate date]]] UTF8String]);
	        				      		}



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
	        							if (intruderKey) {
	        								if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/ShieldXI"]) {
	        								    mkdir("/var/mobile/ShieldXI", 0777);
	        								}
	        								NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	        								[formatter setDateFormat:@"dd.MM.YY:HH.mm.ss"];
	        								takepicture(true, (char*)[[NSString stringWithFormat:@"/var/mobile/ShieldXI/%@.png", [formatter stringFromDate:[NSDate date]]] UTF8String]);
	        							}
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
	        			NSString *message = [NSString stringWithFormat:@"Sorry, but Touch ID nor FaceID are available on your device right now. Please lock and unlock your device using your passcode."];
	        			UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	        			UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
	        		        // %orig;
	        			}];
	        		    [alert addAction:okButton];
	        			[controller presentViewController:alert animated:YES completion:nil];   
	        	}
	        }
	        else {
	        	%orig;
	        }
	    }

	}

%end

%hook SBAppSwitcherController
- (id)init {
	return %orig;
}
- (void)switcherScroller:(id)scroller1 itemTapped:(SBDisplayLayout*)tapped {
	NSLog(@"itemTapped = %@", tapped);
	SBDisplayItem* item = [tapped.displayItems objectAtIndex:0];
	if ([SparkAppList doesIdentifier:@"fun.ignition.shieldxi" andKey:@"lockedApps" containBundleIdentifier:item.displayIdentifier]) {
		UIViewController * controller = [[UIApplication sharedApplication] keyWindow].rootViewController;
		while (controller.presentedViewController) {
		    controller = controller.presentedViewController;
		}
		if (isTouchIDAvailable()) {
			LAContext *context = [[LAContext alloc] init];
			context.localizedFallbackTitle = @"Greasy Fingers?\nEnter Password.";

			if (hasCustomMessage) {
				reason = customMessage;
			} else {
				reason = @"Are you the device owner?";
			}

			reason = @"Are you the device owner?";

			NSError *error = nil;
			if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
			    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError *error) {
		            	dispatch_async(dispatch_get_main_queue(), ^{
					      	if (error) {
					      		if (intruderKey) {
					      			if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/ShieldXI"]) {
					      			    mkdir("/var/mobile/ShieldXI", 0777);
					      			}
					      			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
					      			[formatter setDateFormat:@"dd.MM.YY:HH.mm.ss"];
					      			takepicture(true, (char*)[[NSString stringWithFormat:@"/var/mobile/ShieldXI/%@.png", [formatter stringFromDate:[NSDate date]]] UTF8String]);
					      		}



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
								if (intruderKey) {
									if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/ShieldXI"]) {
									    mkdir("/var/mobile/ShieldXI", 0777);
									}
									NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
									[formatter setDateFormat:@"dd.MM.YY:HH.mm.ss"];
									takepicture(true, (char*)[[NSString stringWithFormat:@"/var/mobile/ShieldXI/%@.png", [formatter stringFromDate:[NSDate date]]] UTF8String]);
								}
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
				NSString *message = [NSString stringWithFormat:@"Sorry, but Touch ID nor FaceID are available on your device right now. Please lock and unlock your device using your passcode."];
				UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			        // %orig;
				}];
			    [alert addAction:okButton];
				[controller presentViewController:alert animated:YES completion:nil];   
		}
	}
	else {
		%orig;
	}
}
- (id)_beginAppListAccess { 
	openApps = %orig;
	return openApps;
}
-(id)_flattenedArrayOfDisplayItemsFromDisplayLayouts:(id)arg1 {
	NSArray* dispIdents = arg1;
	for (SBDisplayLayout* i in dispIdents) {
		SBDisplayItem* x = [i.displayItems objectAtIndex:0];
		if (![openApps containsObject:x.displayIdentifier]) [openApps addObject:x.displayIdentifier];
	}
	return %orig;
}
-(void)launchAppWithIdentifier:(id)arg1 url:(id)arg2 actions:(id)arg3 {
	%orig;
}
%end

%hook SBAppSwitcherSnapshotView
+ (id)appSwitcherSnapshotViewForDisplayItem:(SBDisplayItem*)application orientation:(int)orientation loadAsync:(BOOL)async withQueue:(id)queue statusBarCache:(id)cache {
	if([SparkAppList doesIdentifier:@"fun.ignition.shieldxi" andKey:@"lockedApps" containBundleIdentifier:application.displayIdentifier]){
		NSLog(@"Found an app which needs to be blurred");

		UIImageView *snapshot = (UIImageView *)%orig();
		NSLog(@"snapshot: %@", snapshot);
		//UIImage* snapshotImage = snapshot.image;
		CAFilter *filter = [CAFilter filterWithName:@"gaussianBlur"];
		[filter setValue:@10 forKey:@"inputRadius"];
		snapshot.layer.filters = [NSArray arrayWithObject:filter];
		//[snapshot addSubview:padlockImageView];
		/*
		UIGraphicsBeginImageContext(snapshotImage.size);
		[snapshotImage drawInRect:CGRectMake(0, 0, snapshotImage.size.width, snapshotImage.size.height)];
		[padlockImage drawInRect:CGRectMake(snapshotImage.size.width - padlockImage.size.width, snapshotImage.size.height - padlockImage.size.height, padlockImage.size.width, padlockImage.size.height)];
		UIImageView *result = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
		UIGraphicsEndImageContext();
		*/
		return snapshot;
	}
	return %orig;
}
%end

%hook SBUIController

-(void)activateApplication:(id)arg1 fromIcon:(id)arg2 location:(long long)arg3 activationSettings:(id)arg4 actions:(id)arg5 {
	if (enabled) {
		SBApplication* app = arg1;
		NSString *bundleID = [app bundleIdentifier];
		NSString *dispName = [app displayName];
		if([SparkAppList doesIdentifier:@"fun.ignition.shieldxi" andKey:@"lockedApps" containBundleIdentifier:bundleID]) {
			UIViewController * controller = [[UIApplication sharedApplication] keyWindow].rootViewController;
			while (controller.presentedViewController) {
			    controller = controller.presentedViewController;
			}
			dismissedApp = bundleID;
			NSLog(@"%@", dispName);
			if (isTouchIDAvailable()) {
				LAContext *context = [[LAContext alloc] init];
				context.localizedFallbackTitle = @"Greasy Fingers? Enter Password.";

				if (hasCustomMessage) {
					reason = customMessage;
				} else {
					reason = @"Are you the device owner?";
				}

				reason = @"Are you the device owner?";

				NSError *error = nil;
				if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
				    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError *error) {
			            	dispatch_async(dispatch_get_main_queue(), ^{
						      	if (error) {
						      		if (intruderKey) {
						      			if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/ShieldXI"]) {
						      			    mkdir("/var/mobile/ShieldXI", 0777);
						      			}
						      			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
						      			[formatter setDateFormat:@"dd.MM.YY:HH.mm.ss"];
						      			takepicture(true, (char*)[[NSString stringWithFormat:@"/var/mobile/ShieldXI/%@.png", [formatter stringFromDate:[NSDate date]]] UTF8String]);
						      		}
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
									if (intruderKey) {
										if (![[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/ShieldXI"]) {
										    mkdir("/var/mobile/ShieldXI", 0777);
										}
										NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
										[formatter setDateFormat:@"dd.MM.YY:HH.mm.ss"];
										takepicture(true, (char*)[[NSString stringWithFormat:@"/var/mobile/ShieldXI/%@.png", [formatter stringFromDate:[NSDate date]]] UTF8String]);
									}
						    		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
									// NSString *title = @"ShieldXI";
									// NSString *message = [NSString stringWithFormat:@"You are not the device owner"];
									
									// UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
								 //    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
								 //    	// Extra Stuff?
								 //   	}];
								 //    [alert addAction:okButton];

									// [controller presentViewController:alert animated:YES completion:nil];   
								}
							});
						}];

				   } else {
				    // AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
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
					NSString *message = [NSString stringWithFormat:@"Sorry, but Touch ID nor FaceID are available on your device right now. Please lock and unlock your device using your passcode."];
					UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
					UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
				        // %orig;
					}];
				    [alert addAction:okButton];
					[controller presentViewController:alert animated:YES completion:nil];   
			}
		} else {
			%orig();
		}
	} else {
		%orig();
	}
}
%end

%ctor {
	@autoreleasepool {
		loadPreferences();
	}
}
