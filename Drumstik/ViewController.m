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

@interface ViewController ()

@property (nonatomic, strong) CMMotionManager *manager;
@property (nonatomic, strong) FISoundEngine *engine;
@property (nonatomic, strong) FISound *sound;


@end

@implementation ViewController

bool rebalanced = true;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.engine = [FISoundEngine sharedEngine];
    self.manager = [[CMMotionManager alloc] init];
//    [self.manager setAccelerometerUpdateInterval:0.01];
    
    NSError *error = nil;
    self.sound = [self.engine soundNamed:@"floor-tom-1.wav" maxPolyphony:1 error:&error];
    if (!self.sound) {
        NSLog(@"Failed to load sound: %@", error);
    }
    
    NSOperationQueue *opQ = [NSOperationQueue new];
    [self.manager startAccelerometerUpdatesToQueue:opQ withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        double x = fabs(accelerometerData.acceleration.x);
        double y = fabs(accelerometerData.acceleration.y);
        double z = fabs(accelerometerData.acceleration.z);
        // this approach to being ready for another hit might not be enough
        // might want a vector based approach that considers whether the user
        // is created a force vector in a certain directiont that is sufficient using a sum of
        // the past several points
        if ((x + y + z > 4.2) && rebalanced) {
            NSLog(@"HIT! %f", x + y + z);
            rebalanced = false;
            [self.sound play];
        } else if (x + y + z < 1) {
            rebalanced = true;
        }
    }];
}




@end
