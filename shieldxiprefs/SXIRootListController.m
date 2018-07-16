#include "SXIRootListController.h"
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

#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>
#import<SpringBoard/SBApplicationController.h>
#import <objc/runtime.h>
#import <AudioToolbox/AudioServices.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>

@interface ShieldXIListController : PSListController
// - (void)applicationEnteredForeground:(id)something;
- (void)setEnabledSwitch:(id)value specifier:(PSSpecifier *)specifier;
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

@interface ShieldXICustomCell : PSTableCell
// @property (nonatomic, retain, strong) UIView* contentView;
@end

@interface Applications : PSListController
@end

// #define kSettingsPath @"/Library/PreferenceLoader/Preferences/ShieldXIPrefs.plist"
// #define kSettingsPath @"/var/mobile/Library/Preferences/fun.ignition.shieldxi.plist"
#define kSettingsPath	[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/fun.ignition.shieldxi.plist"]
#define kSettingsIconPath	@"/Library/PreferenceBundles/ShieldXIPrefs.bundle/ShieldXI@2x.png"
#define kSettingsLogoPath	@"/Library/PreferenceBundles/ShieldXIPrefs.bundle/banner@2x.png"

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

// [UIColor colorWithRed:0.45 green:0.42 blue:0.93 alpha:1.0]
@implementation ShieldXIListController

// - (NSArray *)specifiers {
// 	if (!_specifiers) {
// 		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
// 	}

// 	return _specifiers;
// }

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

- (id)initForContentSize:(CGSize)size {
	NSLog(@"[ShieldXI] settings init'd.");
	self = [super initForContentSize:size];
	NSLog(@"[ShieldXI] self is %@", self);

	if (self) {
		NSLog(@"[ShieldXI] IF self is %@", self);

		controller = self;
		// _randNum = 0;
		// _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];

		// add a Respring button to the navbar
		_respringButton = [[UIBarButtonItem alloc] 	initWithTitle:@"Respring"
								  					style:UIBarButtonItemStyleDone 
								  					target:self
								  					action:@selector(respring)];		
		_respringButton.tintColor = [UIColor colorWithRed:212/255.0 green:86/255.0 blue:217/255.0 alpha:1];
		
		[self.navigationItem setRightBarButtonItem:_respringButton];
	}
	return self;
}
// - (id)specifiers {
// 	if (_specifiers == nil) {
// 		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
// 		NSLog(@"read specifiers from plist: %@", _specifiers);
		
// 		// self.timeInputSpecifier = [self specifierForID:@"timeInterval"];
// 		// self.passcodeInputSpecifier = [self specifierForID:@"passcode"];
// 	}
// 	return _specifiers;
// }

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
		self.navigationItem.titleView = iconView;
	}
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	self.navigationController.navigationBar.translucent = YES;
	self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.45 green:0.42 blue:0.93 alpha:1.0];
	// self.tool.barTintColor = [UIColor colorWithRed:0.45 green:0.42 blue:0.93 alpha:1.0];
	// self.toolbar.barStyle = UIBarStyleBlack;
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

- (void)askForLogin {
	if (isTouchIDAvailable()) {
			LAContext *context = [[LAContext alloc] init];
			context.localizedFallbackTitle = @"";

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

@implementation ShieldXICustomCell
- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"ShieldXICustomCell"
					  specifier:specifier];
	if (self) {
		[self setBackgroundColor:[UIColor colorWithRed:0.45 green:0.42 blue:0.93 alpha:1.0]];
		// UIImage *logo = [[UIImage alloc] initWithContentsOfFile:kSettingsLogoPath];
		// if (logo) {
		// 	UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
		// 	logoView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 175);
		// 	[self addSubview:logoView];
		// }
		
		UILabel *randomLabel = [[UILabel alloc] initWithFrame:self.contentView.frame];
		randomLabel.text = @"Thanks for choosing ShieldXI by Ignition";
		randomLabel.font = [UIFont systemFontOfSize:10];
		randomLabel.textColor = UIColor.whiteColor;
	}
	return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 {
	return 100.0f;
}
@end