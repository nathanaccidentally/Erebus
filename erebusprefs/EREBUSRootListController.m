#include "EREBUSRootListController.h"

@implementation EREBUSRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

-(void)respring {
	system("killall SpringBoard");
}

-(void)openDonate {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/nathanaccidentally"]];
}

@end
