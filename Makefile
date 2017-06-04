include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Erebus
Erebus_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall Music; sblaunch com.apple.Music"
SUBPROJECTS += erebusprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
