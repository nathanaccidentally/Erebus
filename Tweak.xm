// Erebus is a dark music app for iOS 10.
// Built by nathanaccidentally.

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
    if (enabled) return [UIColor whiteColor];
    return %orig;
}

-(void)setTextColor:(UIColor *)textColor {
    if(enabled) textColor = [UIColor whiteColor];
    %orig;
}

%end

// Make status bar white

%hook UIStatusBar

-(UIColor *)foregroundColor {
    return [UIColor whiteColor];
}

%end

// Tries (and I think fails) to set the activity indicators to all be white

%hook UIActivityIndicatorView

-(void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)style {
    if(style == UIActivityIndicatorViewStyleGray) style = UIActivityIndicatorViewStyleWhite;
    %orig;
}

-(void)setColor:(UIColor *)color {
    color = [UIColor whiteColor];
    %orig;
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

%hook MusicTabBarPaletteBlurEffect

+(id)effectWithStyle:(long long)arg1 {
    if(arg1 == UIBlurEffectStyleDark) arg1 = UIBlurEffectStyleLight;
    return %orig;
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
	if ([NSStringFromClass([self.superview class]) isEqualToString:@"UIImageView"] && !gradient) [self setHidden:YES];
}

%end

%hook MusicGradientView

-(void)layoutSubviews {
	%orig;
	if (!gradient) [self setHidden:YES];
}

// The gradient views are gradients in the background of things that look ugly.

%end

%hook MPUMarqueeView

-(void)layoutSubviews {
	if (enabled && !artistTitle) {
		[self setHidden:YES];
	}
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
    // We probably don't need this line anyways, but I kept it just in case.
    [self setBackgroundColor:[self backgroundColor]];
}


-(void)setBackgroundColor:(UIColor *)backgroundColor {
    UIColor *origBGColor = backgroundColor;
	if (enabled && !colorFlow) {
		if ([self.superview isMemberOfClass:objc_getClass("Music.ArtworkComponentImageView")] || ([self.superview isMemberOfClass:objc_getClass("_UIVisualEffectContentView")] && colorFlow)) { // If it's an image.
            // do nothing but im lazy
		} else if ([self.superview isMemberOfClass: %c(_TtCV5Music4Text9StackView)] && readTextEnabled) {
            backgroundColor = highContrast ? erebusLightDef : erebusLightDef;
		} else if ([self.superview isMemberOfClass:objc_getClass("Music.NowPlayingTransportControlStackView")]) {
    		backgroundColor = primaryColor;
    	} else {
            backgroundColor = erebusDarkDef;
		}
	}
    if(origBGColor != backgroundColor) backgroundColor = [backgroundColor colorWithAlphaComponent:CGColorGetAlpha(origBGColor.CGColor)];
    %orig;
}

%end

// Compatible with Noctis.
// Thanks to LaughingQuoll and Cyanisaac for help with Noctis support.

%ctor {
	%init(_ungrouped, MusicImageView = objc_getClass("Music.ArtworkComponentImageView"), MusicGradientView = objc_getClass("Music.GradientView"), MusicSearchTextField = objc_getClass("Music.SearchTextField"));

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

		if ([[prefs objectForKey:@"noctisEnabled"] boolValue]) {
			if([noctisPrefs objectForKey:@"enabled"]) {
				noctis = [[noctisPrefs valueForKey:@"enabled"] boolValue];

				if (!noctis) enabled = NO;
			}
		}
	}
}
