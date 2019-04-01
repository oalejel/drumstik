//
//  MultitouchView.m
//  Drumstik
//
//  Created by Omar Al-Ejel on 3/24/19.
//  Copyright © 2019 Omar Al-Ejel. All rights reserved.
//

#import "MultitouchView.h"

@interface MultitouchView ()

@property (nonatomic) int currentTouchCount;

@end

@implementation MultitouchView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.multipleTouchEnabled = true;
    self.currentTouchCount = 0;
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.multipleTouchEnabled = true;
    self.currentTouchCount = 0;
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.currentTouchCount += touches.count;
    
    
    // IDEA: IGNORE touches that begin on the edges of the screen 
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.currentTouchCount = fmax(0, self.currentTouchCount - (int)touches.count);
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.currentTouchCount = 0;
}

- (void)setCurrentTouchCount:(int)currentTouchCount {
    if (currentTouchCount != _currentTouchCount) {
        self.touchCallback(currentTouchCount);
    }
    _currentTouchCount = currentTouchCount;
}

@end
