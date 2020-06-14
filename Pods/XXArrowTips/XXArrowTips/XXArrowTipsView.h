//
//  XXArrowTipsView.h
//  ZAIssue
//
//  Created by hexiang on 2018/7/6.
//  Copyright © 2018年 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XXArrowTipsView;

typedef void(^showAnimationEndBlock)(XXArrowTipsView *view);
typedef void(^showTimerEndBlock)(XXArrowTipsView *view);
typedef void(^pressArrowTipsViewBlock)(XXArrowTipsView *view);

typedef NS_ENUM(NSInteger, XXArrowDirection) {
    XXArrowDirection_Auto,
    XXArrowDirection_Top,
    XXArrowDirection_Bottom
};


@interface XXArrowTipsViewConfigs : NSObject

// 中间文字离边缘的间距(默认为（10, 10, 10, 10）)
@property (nonatomic, assign) UIEdgeInsets  marginEdgeInsets;
// 需要显示的文本(不能为空)
@property (nonatomic, strong) NSString *titleText;
// 渐变的颜色
@property (nonatomic, strong) NSArray *gradientColors;
// 文本字体大小
@property (nonatomic, strong) UIFont *textFont;
// 文本颜色
@property (nonatomic, strong) UIColor *textColor;
// 整个view的cornerRadius
@property (nonatomic, assign) CGFloat  cornerRadius;
// 箭头方向
@property (nonatomic, assign) XXArrowDirection  arrowDirection;

@end

@interface XXArrowTipsView : UIView

/**
 显示箭头view在superView上

 @param superView 父view
 @param point 箭头所指向的父view中的点
 @param configs 箭头view的配置信息
 @return 箭头view
 */
+ (instancetype)showInSuperView:(UIView *)superView point:(CGPoint)point configs:(XXArrowTipsViewConfigs *)configs;

/**
 启动箭头展示定时器
 
 @param block 定时器结束回调
 */
- (void)startShowTimer:(CGFloat)time block:(showTimerEndBlock)block;

/**
 点击箭头view的事件回调
 */
@property (nonatomic, strong) pressArrowTipsViewBlock pressBlock;

@end
