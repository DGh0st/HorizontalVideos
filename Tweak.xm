#import <objc/runtime.h>

@interface AVPlayerViewController : UIViewController
@end

@interface MPMoviePlayerViewController : UIViewController
@end

@interface MPInlineVideoFullscreenViewController : UIViewController
@end

@interface UIDevice (HorizontalVideos)
-(void)setOrientation:(UIInterfaceOrientation)arg1;
@end

UIInterfaceOrientation lastViableOrientation = UIInterfaceOrientationLandscapeRight;
UIInterfaceOrientation previousOrientation = UIInterfaceOrientationPortrait;

BOOL ignorePortrait = NO;

void rotateToLandscape() {
	previousOrientation = [UIDevice currentDevice].orientation;

	[[UIDevice currentDevice] setOrientation:lastViableOrientation];
	[UIViewController attemptRotationToDeviceOrientation];

	ignorePortrait = YES;
}

void rotateToPrevious() {
	ignorePortrait = NO;
	
	[[UIDevice currentDevice] setOrientation:previousOrientation];

	UIInterfaceOrientation orientation = [UIDevice currentDevice].orientation;
	if (UIInterfaceOrientationIsLandscape(orientation))
		lastViableOrientation = orientation;
}

%hook AVPlayerViewController
-(void)viewDidAppear:(BOOL)arg1 {
	rotateToLandscape();
	%orig(arg1);
}

-(void)viewWillDisappear:(BOOL)arg1 {
	rotateToPrevious();
	%orig(arg1);
}

-(void)viewWillTransitionToSize:(CGSize)arg1 withTransitionCoordinator:(id)arg2 {
	if (arg1.width > arg1.height) {
		%orig(arg1, arg2);
		lastViableOrientation = [UIDevice currentDevice].orientation;
	} else if (ignorePortrait) {		
		CGAffineTransform targetRotation = [arg2 targetTransform];
		CGAffineTransform inverseRotation = CGAffineTransformInvert(targetRotation);
		[[UIDevice currentDevice] setOrientation:lastViableOrientation];
		[arg2 animateAlongsideTransition:^(id context) {
			self.view.transform = CGAffineTransformConcat(self.view.transform, inverseRotation);
			self.view.frame = [UIScreen mainScreen].bounds;
		} completion:^(id context) {}];
	} else {
		%orig(arg1, arg2);
	}
}
%end

%hook MPMoviePlayerViewController
-(void)viewDidAppear:(BOOL)arg1 {
	rotateToLandscape();
	%orig(arg1);
}

-(void)viewWillDisappear:(BOOL)arg1 {
	rotateToPrevious();
	%orig(arg1);
}

-(void)viewWillTransitionToSize:(CGSize)arg1 withTransitionCoordinator:(id)arg2 {
	if (arg1.width > arg1.height) {
		%orig(arg1, arg2);
		lastViableOrientation = [UIDevice currentDevice].orientation;
	} else if (ignorePortrait) {		
		CGAffineTransform targetRotation = [arg2 targetTransform];
		CGAffineTransform inverseRotation = CGAffineTransformInvert(targetRotation);
		[[UIDevice currentDevice] setOrientation:lastViableOrientation];
		[arg2 animateAlongsideTransition:^(id context) {
			self.view.transform = CGAffineTransformConcat(self.view.transform, inverseRotation);
			self.view.frame = [UIScreen mainScreen].bounds;
		} completion:^(id context) {}];
	} else {
		%orig(arg1, arg2);
	}
}
%end