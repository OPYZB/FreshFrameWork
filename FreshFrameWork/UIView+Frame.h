//
//  UIView+RSSFrame.h
//  8899
//
//  Created by qq on 15/8/15.
//  Copyright (c) 2015年 yuncheda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

//  高度
@property (nonatomic,assign) CGFloat height;
//  宽度
@property (nonatomic,assign) CGFloat width;

//  Y
@property (nonatomic,assign) CGFloat top;
//  X
@property (nonatomic,assign) CGFloat left;

//  Y + Height
@property (nonatomic,assign) CGFloat bottom;
//  X + width
@property (nonatomic,assign) CGFloat right;


@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;


@end
