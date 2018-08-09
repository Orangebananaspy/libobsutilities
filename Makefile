ARCHS = armv7 arm64

TARGET = iphone:clang

export THEOS_DEVICE_IP = 192.168.0.101

THEOS_BUILD_DIR = Packages

PACKAGE_VERSION = 1.0

DEBUG=0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libOBSUtilities
libOBSUtilities_CFLAGS = -fobjc-arc
libOBSUtilities_FILES = ColorPicker.m ColorSlider.m OBSUtilities.m PSColorCell.m PSCustomSwitchCell.m PSTweakSettings.m
libOBSUtilities_FRAMEWORKS = UIKit Foundation CoreGraphics Accelerate
libOBSUtilities_PRIVATE_FRAMEWORKS = Preferences

after-install::
	install.exec "killall -9 Preferences"

include $(THEOS_MAKE_PATH)/library.mk
