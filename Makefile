include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Erebus
Erebus_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += erebusprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
