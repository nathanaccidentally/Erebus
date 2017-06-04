// Erebus is a dark music app for iOS 10.
// Built by nathanaccidentally. A tired boy.

UIColor *const erebusDarkDef = [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
UIColor *const erebusDarkCtDef = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];
UIColor *const erebusLightDef = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1.0];
UIColor *const erebusWhiteDef = [UIColor whiteColor];
UIColor *primaryColor;
static BOOL enabled = YES;
static BOOL readTextEnabled = YES;
static BOOL gradient = NO;
static BOOL highContrast = YES;
static BOOL colorFlow = NO;
static BOOL noctis = NO;
static BOOL artistTitle = YES;
static NSInteger imageRadius = 6;

// Text color needs to come first.

@interface _TtCV5Music4Text9StackView : UIView
@end

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

// Status bar thanks to AppleBetas.

%hook UIStatusBar

-(UIColor *)foregroundColor {
    return [UIColor whiteColor];
}

%end

%hook MusicImageView

-(CGFloat)_cornerRadius {
	return imageRadius;
}

-(void)layoutSubviews {
	%orig;
	[self setCornerRadius:imageRadius];
}

%end

%hook _TtCVV5Music4Text7Drawing4View

// Should set the background view of the readTextEnabled to rounded corners.

-(CGFloat)_cornerRadius {
	return 6;
}

-(void)layoutSubviews {
	%orig;
	[self setClipsToBounds:YES];
	[self setCornerRadius:6];
}

// ^ Should pad text a little bit to make it more readable.

%end

%hook _TtCV5Music4Text9StackView

-(void)layoutSubviews {
	%orig;
	if ([NSStringFromClass([self.superview class]) isEqualToString:@"UIImageView"] && gradient == NO) {
		%orig;
		[self setHidden:YES];
	}
}

%end

%hook MusicGradientView

-(void)layoutSubviews {
	%orig;
	if (gradient == NO) {
		[self setHidden:YES];
	}
}

// The gradient views are gradients in the background of things that look ugly.

%end

%hook MPUMarqueeView

-(void)layoutSubviews {
	%orig;
	if (enabled && artistTitle == NO && [self.superview isMemberOfClass: %c(UIStackView)]) { // Should hide if it's what we want.
		[self setHidden:YES];
	}
}

%end

// Gonna remove table cells.

%hook UITableView

-(void)setSeparatorStyle:(long long)arg1
{
	%orig(0);
}

%end
	
%hook UITableViewCellSeparatorView

-(void)setSeparatorEffect:(id)arg1
{
	%orig(0);
}

-(id)separatorEffect
{
	return 0;
}
%end

%hook UIView

// ColorFlow 3 support thanks to DavidGoldman and AppleBetas.

-(void)viewDidLoad {
	%orig;
	if (enabled && colorFlow) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorizeUI:) name:@"ColorFlowMusicAppColorizationNotification" object:nil];
	}
}

-(void)colorizeUI:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    primaryColor = userInfo[@"PrimaryColor"];

    if ([self.superview isMemberOfClass:objc_getClass("_UIVisualEffectContentView")]) {
    	[self setBackgroundColor:primaryColor];
    }
}

// ColorFlow over.

-(void)layoutSubviews {
	%orig;
	if (enabled) {
		if ([self.superview isMemberOfClass:objc_getClass("Music.ArtworkComponentImageView")]) {
			// Do nothing.
		} else if ([self.superview isMemberOfClass: %c(_TtCV5Music4Text9StackView)] && readTextEnabled && highContrast == NO) {
			[self setBackgroundColor:erebusLightDef];
		} else if ([self.superview isMemberOfClass: %c(_TtCV5Music4Text9StackView)] && readTextEnabled && highContrast) {
			[self setBackgroundColor:erebusWhiteDef];
		} else if ([self.superview isMemberOfClass:objc_getClass("_UIVisualEffectContentView")] && colorFlow) {
			// Do nothing.
		} else if ([self.superview isMemberOfClass:objc_getClass("Music.NowPlayingTransportControlStackView")]) {
    		[self setBackgroundColor:primaryColor];
    	} else {
			[self setBackgroundColor:erebusDarkDef];
		}
	} else {
		// Do nothing.
	}
}


-(void)setBackgroundColor:(UIColor *)backgroundColor {
	%orig;
	if (enabled && colorFlow == NO) {
		if ([self.superview isMemberOfClass:objc_getClass("Music.ArtworkComponentImageView")]) { // If it's an image.
			// Do nothing.
		} else if ([self.superview isMemberOfClass: %c(_TtCV5Music4Text9StackView)] && readTextEnabled && highContrast == NO) {
			%orig(erebusLightDef);
		} else if ([self.superview isMemberOfClass: %c(_TtCV5Music4Text9StackView)] && readTextEnabled && highContrast) {
			%orig(erebusWhiteDef);
		} else if ([self.superview isMemberOfClass:objc_getClass("_UIVisualEffectContentView")] && colorFlow) {
			// Do nothing.
		} else if ([self.superview isMemberOfClass:objc_getClass("Music.NowPlayingTransportControlStackView")]) {
    		%orig(primaryColor);
    	} else {
			%orig(erebusDarkDef);
		}
	} else {
		// Do nothing.
	}
}

%end

// Compatible with Noctis.
// Thanks to LaughingQuoll and Cyanisaac for help with Noctis support.

%ctor {
	%init(_ungrouped, MusicImageView = objc_getClass("Music.ArtworkComponentImageView"), MusicGradientView = objc_getClass("Music.GradientView"));

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.nathanaccidentally.erebusprefs.plist"];
	NSMutableDictionary *noctisPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.laughingquoll.noctisprefs.plist"];
	NSMutableDictionary *colorFlowPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.golddavid.colorflow3.plist"];

	// ColorFlow 3 Support.

	
	if (colorFlowPrefs) {
		if ([colorFlowPrefs objectForKey:@"MusicEnabled"]) {
			colorFlow = [[colorFlowPrefs valueForKey:@"MusicEnabled"] boolValue];
		}
	}

	if (prefs) {
		if ([prefs objectForKey:@"isEnabled"]) {
			enabled = [[prefs valueForKey:@"isEnabled"] boolValue];
		}

		if ([prefs objectForKey:@"readTextEnabled"]) {
			readTextEnabled = [[prefs valueForKey:@"readTextEnabled"] boolValue];
		}

		if ([prefs objectForKey:@"gradient"]) {
			gradient = [[prefs valueForKey:@"gradient"] boolValue];
		}

		if ([prefs objectForKey:@"highContrast"]) {
			highContrast = [[prefs valueForKey:@"highContrast"] boolValue];
		}

		if ([prefs objectForKey:@"artistTitle"]) {
			artistTitle = [[prefs valueForKey:@"artistTitle"] intValue];
		}

		if ([prefs objectForKey:@"highContrast"]) {
			highContrast = [[prefs valueForKey:@"highContrast"] boolValue];
		}

		// ^ Should allow you to change all images in the Music app radius.

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