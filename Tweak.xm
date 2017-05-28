// Erebus is a dark music app for iOS 10.
// Built by nathanaccidentally.

UIColor *const erebusDarkDef = [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
UIColor *const erebusDarkCtDef = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];
UIColor *const erebusLightDef = [UIColor colorWithRed:0.61 green:0.61 blue:0.61 alpha:1.0];
static BOOL enabled = YES;
static BOOL readTextEnabled = YES;
static BOOL noctis = NO;

// Text color needs to come first.

%hook UILabel

-(UIColor *)textColor {
	if (enabled) {
		return [UIColor whiteColor];
	} else {
		return %orig;
	}
}

-(void)setTextColor:(UIColor *)textColor {
	if (enabled) {
		%orig([UIColor whiteColor]);
	} else {
		return %orig;
	}
}

%end

// Below should fix issues with album corners.

%hook UIImageView

-(void)layoutSubviews {
	if (enabled) {
		if([NSStringFromClass([self.superview class]) isEqualToString:@"Music.ArtworkComponentImageView"]) {
			[self setHidden:YES];
		}
	}
}

%end

%hook MusicImageView

-(CGFloat)_cornerRadius {
	return 6;
}

-(void)layoutSubviews {
	%orig;
	[self setCornerRadius:6];
}

%end

%hook _TtCVV5Music4Text7Drawing4View

-(CGFloat)_cornerRadius {
	return 6;
}

-(void)layoutSubviews {
	%orig;
	[self setCornerRadius:6];
}

%end

%hook UIView

-(void)layoutSubviews {
	if (enabled) {
		if ([NSStringFromClass([self.superview class]) isEqualToString:@"Music.ArtworkComponentImageView"]) {
			%orig;
		} else {
			if ([NSStringFromClass([self.superview class]) isEqualToString:@"_TtCV5Music4Text9StackView"] && readTextEnabled == YES) {
				%orig;
				[self setBackgroundColor:erebusLightDef];
			} else {
				%orig;
				[self setBackgroundColor:erebusDarkDef];
			}
		}
	} else {
		%orig;
	}
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
	if (enabled) {
		if ([NSStringFromClass([self.superview class]) isEqualToString:@"Music.ArtworkComponentImageView"]) { // If it's an image.
			%orig;
		} else {
			if ([NSStringFromClass([self.superview class]) isEqualToString:@"_TtCV5Music4Text9StackView"] && readTextEnabled == YES) {
				%orig(erebusLightDef);
			} else {
				%orig(erebusDarkDef);
			}
		}
	} else {
		%orig;
	}
}

%end

// Compatible with Noctis.

%ctor {
	%init(_ungrouped, MusicImageView = objc_getClass("Music.ArtworkComponentImageView"));

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.nathanaccidentally.erebusprefs.plist"];
	NSMutableDictionary *noctisPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.noctisprefs.plist"];

	if (prefs) {
		if ([prefs objectForKey:@"isEnabled"]) {
			enabled = [[prefs valueForKey:@"isEnabled"] boolValue];
		}

		if ([prefs objectForKey:@"readTextEnabled"]) {
			readTextEnabled = [[prefs valueForKey:@"readTextEnabled"] boolValue];
		}

		if ([[prefs objectForKey:@"noctisEnabled"] boolValue] == YES) {
			if([noctisPrefs objectForKey:@"enabled"]) {
				noctis = [[noctisPrefs valueForKey:@"enabled"] boolValue];

				if (noctis == NO) {
					enabled = NO;
				}
			}

		}
	}
}