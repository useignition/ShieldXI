include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ShieldXIPrefs
ShieldXIPrefs_FILES = SXIRootListController.m
ShieldXIPrefs_INSTALL_PATH = /Library/PreferenceBundles
ShieldXIPrefs_FRAMEWORKS = UIKit LocalAuthentication
ShieldXIPrefs_PRIVATE_FRAMEWORKS = Preferences CoreGraphics ManagedConfiguration AudioToolbox BiometricKit
ShieldXIPrefs_LIBRARIES = sparkapplist
ShieldXIPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ShieldXIPrefs.plist$(ECHO_END)
