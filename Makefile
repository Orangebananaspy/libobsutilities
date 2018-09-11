ARCHS = armv7 arm64

TARGET = iphone:clang

export THEOS_DEVICE_IP = 192.168.0.102

THEOS_BUILD_DIR = Packages

PACKAGE_VERSION = 1.3-2

DEBUG = 0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libOBSUtilities
libOBSUtilities_CFLAGS = -fobjc-arc
libOBSUtilities_FILES = ColorPicker.m ColorSlider.m OBSUtilities.m PSColorCell.m PSCustomSwitchCell.m PSTweakSettings.m OBSModalView.m TweakSettings.m
libOBSUtilities_FRAMEWORKS = UIKit Foundation CoreGraphics Accelerate
libOBSUtilities_PRIVATE_FRAMEWORKS = Preferences

after-install::
	install.exec "killall -9 SpringBoard"

include $(THEOS_MAKE_PATH)/library.mk
