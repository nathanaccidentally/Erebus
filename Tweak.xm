// Erebus is a dark music app for iOS 10.
// Built by nathanaccidentally.

UIColor *const erebusDarkDef = [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
static BOOL enabled = YES;

// Text color needs to come first.

%hook UILabel

-(UIColor *)textColor {
	if(enabled == YES) {
		return [UIColor whiteColor];
	} else {
		return %orig;
	}
}

-(void)setTextColor:(UIColor *)textColor {
	if(enabled == YES) {
		%orig([UIColor whiteColor]);
	} else {
		%orig;
	}
}

%end

// Below should fix issues with album corners.

%hook UIImageView

-(void)layoutSubviews {
	if(enabled == YES) {
		if([NSStringFromClass([self.superview class]) isEqualToString:@"Music.ArtworkComponentImageView"]) {
			[self setHidden:YES];
		}
	}
}

%end

%hook ArtworkImageView

-(CGFloat)_cornerRadius {
	return 8;
}

-(void)_setCornerRadius:(CGFloat)cornerRadius {
	%orig(8);
}

%end

%hook UIView

-(void)layoutSubviews {
	if(enabled == YES) {
		if([NSStringFromClass([self.superview class]) isEqualToString:@"Music.ArtworkComponentImageView"]) {
			%orig;
		} else {
			%orig;
			[self setBackgroundColor:erebusDarkDef];
		}
	} else {
		%orig;
	}
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
	if(enabled == YES) {
		if([NSStringFromClass([self.superview class]) isEqualToString:@"Music.ArtworkComponentImageView"]) { // If it's an image.
			%orig;
		} else {
			%orig(erebusDarkDef);
		}
	} else {
		%orig;
	}
}

%end

%ctor {
	%init(_ungrouped, ArtworkImageView = objc_getClass("Music.ArtworkComponentImageView"));


	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.nathanaccidentally.erebusprefs.plist"];

	if(prefs) {
		if([prefs objectForKey:@"isEnabled"]) {
			enabled = [[prefs valueForKey:@"isEnabled"] boolValue];
		}
	}
}