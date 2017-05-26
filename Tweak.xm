// Erebus is a dark music app for iOS 10.
// Built by nathanaccidentally.

@interface UITableViewCollectionCell : UIView
@end

@interface CompositeCollectionView : UIView
@end

static BOOL enabled = YES;

%hook UITableViewCollectionCell

// Hooks background cells.

-(void)layoutSubviews {
	if(enabled == YES) {
		self.backgroundColor = [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
	} else {
		%orig;
	}
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
	if(enabled == YES) {
		%orig([UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0]);
	} else {
		%orig;
	}
}

// Should set button cells.

%end

%hook CompositeCollectionView

// Doing the same thing as the button cells.

-(void)layoutSubviews {
	if(enabled == YES) {
		self.backgroundColor = [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0];
	} else {
		%orig;
	}
}

-(void)setBackgroundColor:(UIColor *)backgroundColor {
	if(enabled == YES) {
		%orig([UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0]);
	} else {
		%orig;
	}
}

%end

%ctor {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.nathanaccidentally.erebusprefs.plist"];

	if(prefs) {
		if([prefs objectForKey:@"isEnabled"]) {
			enabled = [[prefs valueForKey:@"isEnabled"] boolValue];
		}
	}
}