//
//  SeatingViewController.m
//  ok55leg
//
//  Created by User on 2/13/21.
//  Copyright © 2021 Architactile LLC. All rights reserved.
//

#import "SeatingViewController.h"

@interface SeatingViewController ()

@end

@implementation SeatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *backBtn = (UIButton *)[self.view viewWithTag:9001];
    if ([backBtn isKindOfClass:[UIButton class]]) {
        UIImage *chevron = [UIImage systemImageNamed:@"chevron.left"];
        if (chevron) {
            UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium];
            chevron = [chevron imageByApplyingSymbolConfiguration:config];
            [backBtn setImage:chevron forState:UIControlStateNormal];
            [backBtn setTitle:nil forState:UIControlStateNormal];
            [backBtn setBackgroundImage:nil forState:UIControlStateNormal];
            backBtn.tintColor = [UIColor labelColor];
        }
    }
}
- (IBAction)PanHandler:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}

- (IBAction)PinchHandler:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    
}

- (IBAction)RotationHandler:(UIRotationGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
