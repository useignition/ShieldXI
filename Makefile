include $(THEOS)/makefiles/common.mk

ARCHS= arm64
TWEAK_NAME = ShieldXI
ShieldXI_FILES = Tweak.xm
ShieldXI_FRAMEWORKS = UIKit CoreGraphics QuartzCore LocalAuthentication
ShieldXI_PRIVATE_FRAMEWORKS = SpringBoardServices SpringBoardUIServices AudioToolBox AppSupport BiometricKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
