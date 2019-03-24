//
//  MultitouchView.h
//  Drumstik
//
//  Created by Omar Al-Ejel on 3/24/19.
//  Copyright © 2019 Omar Al-Ejel. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MultitouchView : UIView

@property (nonatomic, copy) void (^touchCallback)(int);

@end

NS_ASSUME_NONNULL_END
