#include "SXIRootListController.h"
#import "SparkAppListTableViewController.h"
#import "SparkAppList.h"
#include <unistd.h>
#include <spawn.h>
#include <sys/wait.h>
#include <dlfcn.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#import <notify.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import<SpringBoard/SBApplicationController.h>
#import <objc/runtime.h>
#import <AudioToolbox/AudioServices.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>

@interface ShieldXIListController : PSListController
// - (void)applicationEnteredForeground:(id)something;
- (void)setEnabledSwitch:(id)value specifier:(PSSpecifier *)specifier;
- (void)setDarkModeSwitch:(id)value specifier:(PSSpecifier *)specifier;
- (void)setIntruderSwitch:(id)value specifier:(PSSpecifier *)specifier;
// - (void)setUseRealPasscodeSwitch:(id)value specifier:(PSSpecifier *)specifier;
// - (void)setTimedPasscodeSwitch:(id)value specifier:(PSSpecifier *)specifier;
// - (void)hidePasscodeAlert;
@end

@interface PSListController (ShieldXI)
-(id)initForContentSize:(CGSize)arg1;
//IOS 8 EXCLUSIVE
-(void)popRecursivelyToRootController;
@end
@interface PSTableCell (ShieldXI)
-(id)initWithStyle:(UITableViewCellStyle)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3;
@end

@interface PSViewController (ShieldXI)
-(void)popRecursivelyToRootController;
@end

@interface ShieldXIListController ()
@property (nonatomic, strong, retain) UIBarButtonItem *respringButton;
// @property (nonatomic, strong, retain) UIAlertView *passcodeAlert;
// @property (nonatomic, strong, retain) UITextField *loginField;
// @property (nonatomic, strong, retain) _UIBackdropView *blurView;
// @property (nonatomic, strong, retain) PSSpecifier *passcodeInputSpecifier;
// @property (nonatomic, strong, retain) PSSpecifier *timeInputSpecifier;
// @property (nonatomic, assign) int randNum;
// @property (nonatomic, assign) BOOL passcodeInputIsShowing;
// @property (nonatomic, strong, retain) UITapGestureRecognizer *tapRecognizer;
@end

// @interface ShieldXICustomCell : PSTableCell
// // @property (nonatomic, retain, strong) UIView* contentView;
// @end

@interface Applications : PSListController
@end

// #define kSettingsPath @"/Library/PreferenceLoader/Preferences/ShieldXIPrefs.plist"
// #define kSettingsPath @"/var/mobile/Library/Preferences/fun.ignition.shieldxi.plist"
#define kSettingsPath	[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/fun.ignition.shieldxi.plist"]
#define kSettingsIconPath	@"/Library/PreferenceBundles/ShieldXIPrefs.bundle/ShieldXI@2x.png"
#define kSettingsLogoPath	@"/Library/PreferenceBundles/ShieldXIPrefs.bundle/banner@2x.png"

static NSMutableDictionary* prefs;
static BOOL darkMode;

__strong ShieldXIListController *controller;

BOOL isTouchIDAvailable() {
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;

    if (![myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        NSLog(@"%@", [authError localizedDescription]);
        return NO;
    }
    return YES;
}

void prefsTouchUnlock() {
	NSLog(@"[ShieldXI] fingerprint valid, unlock Prefs");
	// [controller hidePasscodeAlert];
}

int springboard_restart() {
    NSLog(@"Forking child process to restart springboard");
    pid_t child = fork();
    if(child == 0){
        NSLog(@"Child Process - Restarting springboard");
        // Now we're in child process
        execlp("/bin/launchctl","launchctl","stop","com.apple.SpringBoard",NULL);
        sleep(1);
        exit(1);
    }
    NSLog(@"Child process %d forked, suiciding...",child);
    //exit(1);
    return 0;
}

NSString* osVersionString(){
    return [[NSProcessInfo processInfo] operatingSystemVersionString];
}

static int _osVersionValue = -1;
int osVersion(){
    if(_osVersionValue < 0){
        // We assume the strings is as:
        // Version 1.x.x (Build XXXX)
        NSString* s = osVersionString();
        if([s hasPrefix:@"Version "]){
            if([s length] >= 13 ){
                char buf[] = {0x0,0x0};
                buf[0] = [s characterAtIndex:8];
                int i1 = atoi(buf);
                buf[0] = [s characterAtIndex:10];
                int i2 = atoi(buf);
                buf[0] = [s characterAtIndex:12];
                int i3 = atoi(buf);
                _osVersionValue = i1 * 100 + i2 * 10 + i3;
                NSLog(@"OS Version is %d",_osVersionValue);
                return _osVersionValue;
            }
        }
        _osVersionValue = 0;
    }
    return _osVersionValue;
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
	
	if (prefs[@"darkMode"] && ![prefs[@"darkMode"] boolValue]) {
		darkMode = NO;
	} else {
		darkMode = YES;
	}
	NSLog(@"setting for darkMode: %d", darkMode);
}

// [UIColor colorWithRed:0.45 green:0.42 blue:0.93 alpha:1.0]
@implementation ShieldXIListController

// - (NSArray *)specifiers {
// 	if (!_specifiers) {
// 		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
// 	}

// 	return _specifiers;
// }

-(void)selectLockedApps {

    SparkAppListTableViewController* s = [[SparkAppListTableViewController alloc] initWithIdentifier:@"fun.ignition.shieldxi" andKey:@"lockedApps"];

    [self.navigationController pushViewController:s animated:YES];
    self.navigationItem.hidesBackButton = FALSE;
}

-(void)openTwitter {
	NSString *user = @"useignition";
	if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
	} else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
	} else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
	} else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
	}
}

-(void)visitIgnitionFun {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://ignition.fun"]];
}

-(void)openSourceCode {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/useignition/ShieldXI"]];
}

- (id)initForContentSize:(CGSize)size {
	NSLog(@"[ShieldXI] settings init'd.");
	self = [super initForContentSize:size];
	NSLog(@"[ShieldXI] self is %@", self);

	if (self) {
		NSLog(@"[ShieldXI] IF self is %@", self);

		controller = self;
		_respringButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
		
		[self.navigationItem setRightBarButtonItem:_respringButton];
	}
	return self;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)setTitle:(id)title {
	[super setTitle:title];
	
	UIImage *icon = [[UIImage alloc] initWithContentsOfFile:kSettingsIconPath];
	if (icon) {
		UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
		iconView.layer.cornerRadius = iconView.frame.size.height /2;
		iconView.layer.masksToBounds = YES;
		iconView.layer.borderWidth = 0;
		self.navigationItem.titleView = iconView;
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (instancetype)init {
	loadPreferences();
	self = [super init];

	if (self) {
		if (darkMode) {
			HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
			appearanceSettings.navigationBarTintColor = [UIColor whiteColor];
			appearanceSettings.navigationBarTitleColor = [UIColor whiteColor];
			appearanceSettings.statusBarTintColor = [UIColor whiteColor];
			appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithRed:0.24 green:0.25 blue:0.32 alpha:1.0];
			appearanceSettings.translucentNavigationBar = NO;
			appearanceSettings.tintColor = [UIColor colorWithRed:0.38 green:0.45 blue:0.64 alpha:1.0];
			appearanceSettings.navigationBarBackgroundColor = [UIColor colorWithRed:0.27 green:0.28 blue:0.35 alpha:1.0];
			appearanceSettings.tableViewCellTextColor = [UIColor whiteColor];
			appearanceSettings.tableViewCellBackgroundColor = [UIColor colorWithRed:0.27 green:0.28 blue:0.35 alpha:1.0];
			appearanceSettings.tableViewCellSelectionColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.35 alpha:1.0];
			appearanceSettings.tableViewBackgroundColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.21 alpha:1.0];
			self.hb_appearanceSettings = appearanceSettings;
		} else {
			HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
			appearanceSettings.navigationBarBackgroundColor = [UIColor colorWithRed:0.45 green:0.42 blue:0.93 alpha:1.0];
			appearanceSettings.navigationBarTintColor = [UIColor whiteColor];
			appearanceSettings.navigationBarTitleColor = [UIColor whiteColor];
			appearanceSettings.statusBarTintColor = [UIColor whiteColor];
			appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
			appearanceSettings.translucentNavigationBar = NO;
			appearanceSettings.tintColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1];
			self.hb_appearanceSettings = appearanceSettings;
		}
	}

	return self;
}

- (void)viewWillAppear {
	[self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[[SparkAppList alloc] getAppList: ^(NSArray *result) {
        [defaults setValue:[NSString stringWithFormat:@"%lu", (long)[result count]] forKey:@"lockedAppsCount"];
        [defaults synchronize];
    }];
	NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
	// self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	// self.navigationController.navigationBar.translucent = YES;
	// self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.45 green:0.42 blue:0.93 alpha:1.0];
	// self.tool.barTintColor = [UIColor colorWithRed:0.45 green:0.42 blue:0.93 alpha:1.0];
	// self.toolbar.barStyle = UIBarStyleBlack;
	[self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
	[self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];

	// if (@available(iOS 11.0, *)) {
	//     [self.navigationController.navigationBar setLargeTitleTextAttributes:titleAttributes];
	// }

	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];

	[self setNeedsStatusBarAppearanceUpdate];
	[self askForLogin];
}

- (void)setEnabledSwitch:(id)value specifier:(PSSpecifier *)specifier {
	NSLog(@"setting: %@ for key: %@", value, [specifier propertyForKey:@"key"]);
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// indicate that a Respring is required
	self.respringButton.title = @"Respring";
}

- (void)setIntruderSwitch:(id)value specifier:(PSSpecifier *)specifier {
	NSLog(@"setting: %@ for key: %@", value, [specifier propertyForKey:@"key"]);
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// indicate that a Respring is required
	self.respringButton.title = @"Respring";
}

- (void)setDarkModeSwitch:(id)value specifier:(PSSpecifier *)specifier {
	NSLog(@"setting: %@ for key: %@", value, [specifier propertyForKey:@"key"]);
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// indicate that a Respring is required
	self.respringButton.title = @"Respring";
	// [self init];
}

- (void)askForLogin {
	if (isTouchIDAvailable()) {
			LAContext *context = [[LAContext alloc] init];
			context.localizedFallbackTitle = @"Greasy Fingers? Enter Password.";

			NSError *error = nil;
			if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
			    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Are you the device owner?" reply:^(BOOL success, NSError *error) {
		            	dispatch_async(dispatch_get_main_queue(), ^{
					      	if (error) {
					      		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
								NSString *title = @"ShieldXI";
								NSString *message = [NSString stringWithFormat:@"There was a problem verifying your identity."];
								
								UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
							    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
							    	// Extra Stuff?
							    	[self.rootController popRecursivelyToRootController];
							   	}];

							    [alert addAction:okButton];

								[controller presentViewController:alert animated:YES completion:nil];   
					        }

					  		if (success) {
					  			// %orig();
							} else {
					    		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
								NSString *title = @"ShieldXI";
								NSString *message = [NSString stringWithFormat:@"You are not the device owner"];
								
								UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
							    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
							    	// Extra Stuff?
							    	[self.rootController popRecursivelyToRootController];
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
			    	[self.rootController popRecursivelyToRootController];
			   	}];
			    [alert addAction:okButton];
				[controller presentViewController:alert animated:YES completion:nil];   
			}
	} else {
			NSString *title = @"ShieldXI";
			NSString *message = [NSString stringWithFormat:@"Sorry, but Touch ID nor FaceID are available on your device. DM us on @useignition as we would like to know how you got this running on your device!"];
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		        // %orig;
		        [self.rootController popRecursivelyToRootController];
			}];
		    [alert addAction:okButton];
			[controller presentViewController:alert animated:YES completion:nil];   
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			
			// [self.rootController popRecursivelyToRootController];
	}
}

- (void)respring {
	NSLog(@"ShieldXI respring...");
	pid_t pid;
	int status;
	const char* args[] = {"killall", "-9", "SpringBoard", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
	waitpid(pid, &status, WEXITED);//wait untill the process completes (only if you need to do that)
	springboard_restart();
}

@end

// @implementation ShieldXICustomCell
// - (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
// 	self = [super initWithStyle:UITableViewCellStyleDefault
// 				reuseIdentifier:@"ShieldXICustomCell"
// 					  specifier:specifier];
// 	if (self) {
// 		[self setBackgroundColor:[UIColor colorWithRed:0.45 green:0.42 blue:0.93 alpha:1.0]];
// 		// UIImage *logo = [[UIImage alloc] initWithContentsOfFile:kSettingsLogoPath];
// 		// if (logo) {
// 		// 	UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
// 		// 	logoView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 175);
// 		// 	[self addSubview:logoView];
// 		// }
		
// 		// UILabel *randomLabel = [[UILabel alloc] initWithFrame:self.contentView.frame];
// 		// randomLabel.text = @"Thanks for choosing ShieldXI by Ignition";
// 		// randomLabel.font = [UIFont systemFontOfSize:10];
// 		// randomLabel.textColor = UIColor.whiteColor;
// 		int width = self.contentView.bounds.size.width;
// 		int height = self.contentView.bounds.size.height;

// 		CGRect frame = CGRectMake(0, 45, width, height);
// 		CGRect subtitleFrame = CGRectMake(0, 75, width, height);

// 		UILabel *tweakTitle = [[UILabel alloc] initWithFrame:frame];
// 		[tweakTitle setNumberOfLines:1];
// 		[tweakTitle setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48]];
// 		[tweakTitle setText:@"ShieldXI"];
// 		[tweakTitle setBackgroundColor:[UIColor clearColor]];
// 		[tweakTitle setTextColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:1]];
// 		[tweakTitle setTextAlignment:NSTextAlignmentCenter];
// 		tweakTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
// 		tweakTitle.contentMode = UIViewContentModeScaleToFill;

// 		UILabel *tweakSubtitle = [[UILabel alloc] initWithFrame:subtitleFrame];
// 		[tweakSubtitle setNumberOfLines:1];
// 		[tweakSubtitle setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:18]];
// 		[tweakSubtitle setText:@"By Ignition Development"];
// 		[tweakSubtitle setBackgroundColor:[UIColor clearColor]];
// 		[tweakSubtitle setTextColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:1]];
// 		[tweakSubtitle setTextAlignment:NSTextAlignmentCenter];
// 		tweakSubtitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
// 		tweakSubtitle.contentMode = UIViewContentModeScaleToFill;

// 		[self addSubview:tweakTitle];
// 		[self addSubview:tweakSubtitle];
// 	}
// 	return self;
// }
// - (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
// 	return 150.0f;
// }
// @end