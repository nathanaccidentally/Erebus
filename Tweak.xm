// Erebus is a dark music app for iOS 10.
// Built by nathanaccidentally.

UIColor *const erebusDarkDef = [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
UIColor *const clear = [UIColor clearColor];
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

// Let's set the top bar.

%hook UIView

-(void)layoutSubviews {
	if(enabled == YES) {
		%orig;
		[self setBackgroundColor:erebusDarkDef];
	} else {
		%orig;
	}
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
	if(enabled == YES) {
		%orig(erebusDarkDef);
	} else {
		%orig;
	}
}

%end

// First thing is images. (To fix at least)

%hook UIImageView

-(void)layoutSubviews {
	if(enabled == YES) {
		%orig;
		[self setBackgroundColor:clear];
	}
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
	if(enabled == YES) {
		%orig(clear);
	} else {
		%orig;
	}
}

%end

%hook MusicArtView

-(void)layoutSubviews {
	if(enabled == YES) {
		%orig;
		[self setBackgroundColor:clear];
	}
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
	if(enabled == YES) {
		%orig(clear);
	} else {
		%orig;
	}
}

%end

%ctor {
	%init(_ungrouped, MusicArtView = objc_getClass("Music.ArtworkComponentImageView"));

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.nathanaccidentally.erebusprefs.plist"];

	if(prefs) {
		if([prefs objectForKey:@"isEnabled"]) {
			enabled = [[prefs valueForKey:@"isEnabled"] boolValue];
		}
	}
}