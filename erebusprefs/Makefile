include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ErebusPrefs
ErebusPrefs_FILES = EREBUSRootListController.m
ErebusPrefs_INSTALL_PATH = /Library/PreferenceBundles
ErebusPrefs_FRAMEWORKS = UIKit
ErebusPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ErebusPrefs.plist$(ECHO_END)
