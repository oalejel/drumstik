//
//  ViewController.m
//  Drumstik
//
//  Created by Omar Al-Ejel on 3/22/19.
//  Copyright © 2019 Omar Al-Ejel. All rights reserved.
//

#import "ViewController.h"
#import "FISoundEngine.h"
#import <CoreMotion/CoreMotion.h>
#import "MultitouchView.h"

@interface ViewController ()

@property (nonatomic, strong) CMMotionManager *manager;
@property (nonatomic, strong) FISoundEngine *engine;
//@property (nonatomic, strong) FISound *sound;
@property (nonatomic, strong) NSMutableArray *sounds;
@property (nonatomic, strong) UIImageView *stickImageview;
@property (nonatomic, strong) UIView *spotlightEffectView;
@property (weak, nonatomic) IBOutlet UILabel *fingerCountLabel;

@end

@implementation ViewController

bool rebalanced = true;
int currentTouchCount = 0;

int balance_count = 0;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup thematic elements
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self addSpotlightView];
    [self addParallaxEffect];
    
    // setup accelerometer
    self.manager = [[CMMotionManager alloc] init];
//    [self.manager setAccelerometerUpdateInterval:0.01];
    
    __weak ViewController *weakSelf = self;
    [(MultitouchView *)self.view setTouchCallback:^(int _touchCount) {
        currentTouchCount = _touchCount;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.fingerCountLabel.text = [NSString stringWithFormat:@"Finger Count: %d", _touchCount];
        });
    }];
    
//    // create gesture recognizer to track number of finger s
//    for (int i = 1; i < 5; i++) {
//        UILongPressGestureRecognizer *rec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognized:)];
//        [rec setMinimumPressDuration:0.05];
//        rec.numberOfTouchesRequired = i;
//        [self.view addGestureRecognizer:rec];
//    }
    
    // prepare audio engine
    self.engine = [FISoundEngine sharedEngine];
    NSArray *soundFilenames = @[@"floor-tom-1.wav", @"snare-1.wav", @"snare-rim-1.wav", @"kick-drum-1.wav"];
    self.sounds = [[NSMutableArray alloc] initWithCapacity:7];
    for (NSString *fname in soundFilenames) {
        NSError *error = nil;
        FISound *sound = [self.engine soundNamed:fname maxPolyphony:4 error:&error];
        [self.sounds addObject:sound];
        if (!sound) {
            NSLog(@"Failed to load sound: %@", error);
        }
    }
    
    NSOperationQueue *opQ = [NSOperationQueue new];
    [self.manager startAccelerometerUpdatesToQueue:opQ withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        double x = fabs(accelerometerData.acceleration.x);
        double y = fabs(accelerometerData.acceleration.y);
        double z = fabs(accelerometerData.acceleration.z);
        double sum = x + y + z;
        // this approach to being ready for another hit might not be enough
        // might want a vector based approach that considers whether the user
        // is created a force vector in a certain directiont that is sufficient using a sum of
        // the past several points
//        NSLog(@"%f, %f, %f", x, y, z);
        if (sum > 9 || (rebalanced && (sum > 3.9))) {
            NSLog(@"HIT! %f with %d fingers", sum, currentTouchCount);
            rebalanced = false;
            if (self.sounds.count > 0) {
                int soundIndex = fmax(0, fmin(self.sounds.count - 1, currentTouchCount));
                [self.sounds[soundIndex] play];
                [self animateStrike];
            }
        } else if (sum < 2.2) {
            balance_count++;
            if (balance_count > 3) {
                balance_count = 0;
                rebalanced = true;
            }
        }
    }];
}

bool layedOutSubviews = false;
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!layedOutSubviews) {
        layedOutSubviews = true;
        
        self.stickImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stick"]];
        [self.stickImageview setContentMode:UIViewContentModeScaleAspectFit];
        self.stickImageview.clipsToBounds = false;
        self.stickImageview.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height);
        [self.view addSubview:self.stickImageview];
    }
    
}

//- (void)gestureRecognized:(UIGestureRecognizer *)rec {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        int last = currentFingerCount;
//        if ([rec state] == UIGestureRecognizerStateEnded) {
//            currentFingerCount = 0;
//        } else {
//            currentFingerCount = (int)[rec numberOfTouches];
//        }
//        if (currentFingerCount != last) {
//            self.fingerCountLabel.text = [NSString stringWithFormat:@"Finger Count: %d", currentFingerCount];
//        }
//    });
//}

// make drumstick image view appear to be striking an invisible object
- (void)animateStrike {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateKeyframesWithDuration:0.2 delay:0 options:0 animations:^{
            [self.spotlightEffectView setAlpha:0.7];
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:0.2 delay:0 options:0 animations:^{
                [self.spotlightEffectView setAlpha:1];
            } completion:^(BOOL finished) {
                
            }];
        }];
    });
    
}

- (void)addSpotlightView {
    CGRect effectRect = CGRectMake(0, 0, 0.5 * self.view.frame.size.width, self.view.frame.size.width);
    self.spotlightEffectView = [[UIView alloc] initWithFrame:effectRect];
    [self.spotlightEffectView.layer setCornerRadius:0.25 * self.view.frame.size.width];
    [self.spotlightEffectView setBackgroundColor:[UIColor blackColor]];
    [self.spotlightEffectView.layer setShadowColor:[[UIColor whiteColor] CGColor]];
    [self.spotlightEffectView.layer setShadowOpacity:0.6];
    [self.spotlightEffectView.layer setShadowOffset:CGSizeMake(0, 0.75*self.view.frame.size.width)];
    [self.spotlightEffectView.layer setShadowRadius:120];
    [self.spotlightEffectView.layer setMasksToBounds:false];
    [self.spotlightEffectView setClipsToBounds:false];
    self.spotlightEffectView.center = CGPointMake(0.5 * self.view.frame.size.width, -0.5*self.spotlightEffectView.frame.size.height);
    [self.view addSubview:self.spotlightEffectView];
}

- (void)addParallaxEffect {
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-10);
    verticalMotionEffect.maximumRelativeValue = @(10);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-10);
    horizontalMotionEffect.maximumRelativeValue = @(10);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [self.view addMotionEffect:group];
}

//- (int)currentFingerCount


@end
