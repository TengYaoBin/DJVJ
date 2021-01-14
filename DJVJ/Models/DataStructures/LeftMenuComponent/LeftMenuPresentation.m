//
//  LeftMenuPresentation.m
//  LeftSideMenuControllerDemo

#import "LeftMenuPresentation.h"
#import "GlobalData.h"

@interface LeftMenuPresentation()

@property (nonatomic,strong) UIView *dimmingView;   // shadow

@end

@implementation LeftMenuPresentation

-(void)presentationTransitionWillBegin {    
    
    self.dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    self.dimmingView.backgroundColor = [UIColor blackColor];
    
    

    [self.dimmingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)]];
    
    [self.containerView addSubview:self.dimmingView];
    
    // Get the transition coordinator for the presentation so we can
    // fade in the dimmingView alongside the presentation animation.
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    self.dimmingView.alpha = 0.f;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0.5f;
    } completion:NULL];
}

-(void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}

-(void)dismissalTransitionWillBegin {
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0.f;
    } completion:NULL];
    
}

- (void)dismissalTransitionDidEnd:(BOOL)completed{
    if (completed) {
        [self.dimmingView removeFromSuperview];
    }
}

// frame of present viewController
- (CGRect)frameOfPresentedViewInContainerView{
    CGFloat windowH = [UIScreen mainScreen].bounds.size.height;
    self.presentedView.frame = CGRectMake(0, 0, PRESENTATION_W, windowH);
    return self.presentedView.frame;
}

#pragma mark - action

- (void)dimmingViewTapped:(UITapGestureRecognizer*)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
