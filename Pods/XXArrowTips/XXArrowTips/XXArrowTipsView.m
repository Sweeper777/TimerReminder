//
//  XXArrowTipsView.m
//  ZAIssue
//
//  Created by hexiang on 2018/7/6.
//  Copyright © 2018年 MAC. All rights reserved.
//

#import "XXArrowTipsView.h"
#import "UIView+ColorOfPoint.h"

#define kGradientStartColor [UIColor colorWithRed:176.0/255.0f green:108.0/255.0f blue:239.0/255.0f alpha:1.0f]
#define kGradientEndColor [UIColor colorWithRed:128.0/255.0f green:112.0/255.0f blue:241.0/255.0f alpha:1.0f]

#define kDefaultTitleLabelBackgroundColor [UIColor colorWithRed:124.0/255.0f green:115.0/255.0f blue:255.0/255.0f alpha:1.0f]
#define angle2Radian(angle) ((angle)/180.0*M_PI)

static CGSize  kSizeOfArrowLabel = (CGSize){8, 8};    //   箭头的大小

static CGFloat kViewMargin = 10.0f;    //
static CGFloat kArrowInterval = 10.0f;    //

@interface XXArrowTipsView()<CAAnimationDelegate>
{
    NSTimer *_timer;
    
    showTimerEndBlock _endBlock;
    showAnimationEndBlock _animationEndBlock;
}

@property (nonatomic, strong) UILabel *backgroundLabel;
@property (nonatomic, strong) UIButton *pressButton;
@property (nonatomic, strong) UILabel *arrowLabel;

@property (nonatomic, assign) CGFloat arrowOffset;  // 箭头离左边的偏移量

@property (nonatomic, strong) XXArrowTipsViewConfigs *viewConfigs;

@end

@implementation XXArrowTipsView

#pragma mark - Public Interface

- (void)startShowTimer:(CGFloat)time block:(showTimerEndBlock)block {
    _endBlock = block;
    
    [self startTimer:time];
}

- (void)startViewAnimation:(CGFloat)time block:(showAnimationEndBlock)block {
    
    _animationEndBlock = block;
    [self.pressButton setTitle:nil forState:UIControlStateNormal];
    
    CGFloat animationTime = time;
    
    CGFloat scaleRatio = 0.2f;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSNumber numberWithFloat:scaleRatio]; // 开始时的倍率
    animation.toValue = [NSNumber numberWithFloat:1]; // 结束时的倍率
    
    CGFloat yTo, yFrom;
    NSInteger page = (NSInteger)(1.0f / scaleRatio);
    CGFloat viewWidth = self.frame.size.width;
    CGFloat viewHeight = self.frame.size.height;
    NSInteger pageLength = (NSInteger)(viewWidth / page);
    NSInteger currentPage = (NSInteger)(self.arrowOffset / pageLength );
    CGFloat xTo = viewWidth / 2;
    CGFloat xFrom =  currentPage * pageLength + pageLength / 2;
    switch (self.viewConfigs.arrowDirection) {
        case XXArrowDirection_Top:
        {
            yTo = viewHeight / 2 + kSizeOfArrowLabel.height / 2;
            yFrom = viewHeight * scaleRatio / 2 +  kSizeOfArrowLabel.height / 2;
            break;
        }
        case XXArrowDirection_Bottom:
        {
            yTo = viewHeight / 2 - kSizeOfArrowLabel.height / 2;
            yFrom = viewHeight - (viewHeight * scaleRatio / 2 +  kSizeOfArrowLabel.height / 2);
            break;
        }
        case XXArrowDirection_Auto:
        default:
        {
            yTo = viewHeight / 2 + kSizeOfArrowLabel.height / 2;
            yFrom = viewHeight * scaleRatio / 2 +  kSizeOfArrowLabel.height / 2;
            break;
        }
    }
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
    animation1.fromValue = [NSValue valueWithCGPoint:CGPointMake(xFrom, yFrom)]; // 起始帧
    animation1.toValue = [NSValue valueWithCGPoint:CGPointMake(xTo, yTo)]; // 终了帧
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = animationTime;
    group.repeatCount = 1;
    group.animations = [NSArray arrayWithObjects:animation, animation1, nil];
    group.delegate = self;
    [self.backgroundLabel.layer addAnimation:group forKey:@"scaleAnimation"];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation2.fromValue = @(0.4); // 起始帧
    animation2.toValue = @(1.0); // 终了帧
    animation2.duration = animationTime;
    animation2.repeatCount = 1;
    
    [self.layer addAnimation:animation2 forKey:@"opacityAnimation"];
}


+ (instancetype)showInSuperView:(UIView *)superView point:(CGPoint)point configs:(XXArrowTipsViewConfigs *)configs {
    
    if ( ![superView.layer containsPoint:point] ) {
        NSLog(@"point not in superView");
        return nil;
    }
    
    if ( nil == configs.titleText || 0 == configs.titleText.length ) {
        NSLog(@"文本不能为空");
        return nil;
    }
    
    CGSize maxSize = CGSizeMake(superView.bounds.size.width - 2 * kViewMargin, ceil(configs.textFont.lineHeight) + 1 );
    CGRect frame  = [configs.titleText boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:configs.textFont} context:nil];
    frame.size.width += (configs.marginEdgeInsets.left + configs.marginEdgeInsets.right);
    frame.size.height += (configs.marginEdgeInsets.top + configs.marginEdgeInsets.bottom);
    CGFloat height = frame.size.height;
    
    XXArrowDirection direction = XXArrowDirection_Bottom;
    if (configs.arrowDirection == XXArrowDirection_Auto) {
        if(point.y <= height + kViewMargin )
            direction = XXArrowDirection_Top;
    } else {
        direction = configs.arrowDirection;
    }
    
    CGSize size = (CGSize){ceil(frame.size.width), ceil(frame.size.height)};
    CGSize superViewSize = superView.bounds.size;
    CGFloat arrowOffset = size.width / 2;
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    
    // 计算yPos
    switch (direction) {
        case XXArrowDirection_Bottom:
        {
            yPos = point.y - size.height - kArrowInterval;
            break;
        }
        case XXArrowDirection_Top:
        {
            yPos = point.y;
            break;
        }
        default:
            break;
    }
    
    // 计算xPos
    if (point.x <=  kViewMargin) {
        xPos = 0;
    }else if (point.x < size.width / 2 + kViewMargin) {
        xPos = (point.x <=  kSizeOfArrowLabel.width / 2 + kViewMargin ?  kViewMargin -  kSizeOfArrowLabel.width / 2: kViewMargin); // 此处需要微调
    } else if(point.x > superViewSize.width - kViewMargin) {
        xPos = superViewSize.width - size.width;
    } else if(point.x > superViewSize.width - size.width / 2 - kViewMargin) {
        xPos = superViewSize.width - size.width - kViewMargin;
    } else {
        xPos = point.x - size.width / 2;
    }
    arrowOffset = point.x - xPos;
    // 最小和最大偏移特殊处理
    if (arrowOffset <= 0.0) {
        arrowOffset = 1.0f;
    }
    if ( arrowOffset >= ceil(size.width)) {
        arrowOffset = ceil(size.width) - 1.0f;
    }
    
    CGRect viewFrame = CGRectMake(ceil(xPos), ceil(yPos), ceil(size.width), ceil(size.height));
    XXArrowTipsView *view = [[XXArrowTipsView alloc] initWithFrame:viewFrame arrowOffset:arrowOffset configs:configs];
    [superView addSubview:view];
    return view;
}

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame arrowOffset:(CGFloat)arrowOffset configs:(XXArrowTipsViewConfigs *)configs {
    self = [super initWithFrame:frame];
    if (self) {
        self.arrowOffset = arrowOffset;
        self.viewConfigs = configs;
        [self setupUI];
        [self.pressButton setTitle:configs.titleText forState:UIControlStateNormal];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s: ", __func__);
    [self stopTimer];
}

#pragma mark - Event Response

- (void)timerEndAction:(NSTimer *)timer {
    __weak typeof(self)weakSelf = self;
    if (_endBlock) {
        _endBlock(weakSelf);
        _endBlock  = nil;
    }
    [self removeFromSuperview];
}

- (void)pressButtonAction:(UIButton *)button {
    __weak typeof(self)weakSelf = self;
    if (self.pressBlock) {
        self.pressBlock(weakSelf);
        self.pressBlock  = nil;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    [self.pressButton setTitle:self.viewConfigs.titleText forState:UIControlStateNormal];
    __weak typeof(self)weakSelf = self;
    if (_animationEndBlock) {
        _animationEndBlock(weakSelf);
        _animationEndBlock  = nil;
    }
}

#pragma mark - Private Methods

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat height = self.bounds.size.height;
    CGRect labelFrame = CGRectZero;
    CGRect arrowFrame = CGRectZero;
    // 位置最小化处理
    CGFloat xPos = (self.arrowOffset <= kSizeOfArrowLabel.width / 2 ? kSizeOfArrowLabel.width / 2 : self.arrowOffset - kSizeOfArrowLabel.width / 2);
    // 位置最大化处理
    xPos = (self.arrowOffset >= self.bounds.size.width - kSizeOfArrowLabel.width / 2 ? self.bounds.size.width - kSizeOfArrowLabel.width / 2 : self.arrowOffset - kSizeOfArrowLabel.width / 2);
    
    switch (self.viewConfigs.arrowDirection) {
        case XXArrowDirection_Bottom:
        {
            labelFrame = CGRectMake(0, 0, self.bounds.size.width, height - kSizeOfArrowLabel.height /2);
            arrowFrame = CGRectMake(xPos, height - kSizeOfArrowLabel.height , kSizeOfArrowLabel.width, kSizeOfArrowLabel.height);
            break;
        }
        case XXArrowDirection_Top:
        {
            labelFrame = CGRectMake(0, kSizeOfArrowLabel.height / 2, self.bounds.size.width, height - kSizeOfArrowLabel.height /2);
            arrowFrame = CGRectMake(xPos, 0, kSizeOfArrowLabel.width, kSizeOfArrowLabel.height);
            break;
        }
        default:
            break;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.layer.cornerRadius = self.viewConfigs.cornerRadius;
    label.layer.masksToBounds = YES;
    label.backgroundColor = kDefaultTitleLabelBackgroundColor;
    label.font = self.viewConfigs.textFont;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    self.backgroundLabel = label;
    
    UILabel *arrowLabel = [[UILabel alloc] initWithFrame:arrowFrame];
    arrowLabel.backgroundColor = kDefaultTitleLabelBackgroundColor;
    arrowLabel.transform = CGAffineTransformMakeRotation(angle2Radian(45.0f));
    self.arrowLabel = arrowLabel;
    
    NSArray *colors = self.viewConfigs.gradientColors;
    if (nil != colors && 0 != colors.count) {
        self.backgroundLabel.backgroundColor = [UIColor clearColor];
        self.arrowLabel.backgroundColor = [UIColor clearColor];
        NSMutableArray *arCGColors = [NSMutableArray array];
        for(UIColor *c in colors) {
            [arCGColors addObject:(id)c.CGColor];
        }
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.backgroundLabel.bounds;
        gradientLayer.locations = @[@0, @1];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 0);
        gradientLayer.colors = arCGColors;
        [self.backgroundLabel.layer addSublayer:gradientLayer];
        
        UIColor *sColor = [self.backgroundLabel colorOfPoint:(CGPoint){arrowFrame.origin.x, arrowFrame.origin.y}];
        UIColor *eColor = [self.backgroundLabel colorOfPoint:(CGPoint){arrowFrame.origin.x + arrowFrame.size.width, arrowFrame.origin.y}];
        CAGradientLayer *arrowGradientLayer = [CAGradientLayer layer];
        arrowGradientLayer.frame = self.arrowLabel.bounds;
        arrowGradientLayer.locations = @[@0, @1];
        arrowGradientLayer.startPoint = CGPointMake(0, 1);
        arrowGradientLayer.endPoint = CGPointMake(1, 0);
        arrowGradientLayer.colors = @[(id)sColor.CGColor, (id)eColor.CGColor];
        [self.arrowLabel.layer addSublayer:arrowGradientLayer];
    }
    
    self.pressButton = ({
        
        UIButton *button = [[UIButton alloc] initWithFrame:labelFrame];
        [button addTarget:self action:@selector(pressButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:self.viewConfigs.textColor forState:UIControlStateNormal];
        button.titleLabel.font = self.viewConfigs.textFont;
        button;
    });
    
    [self addSubview:self.arrowLabel];
    [self addSubview:self.backgroundLabel];
    [self addSubview:self.pressButton];
}

#pragma mark -- Timer

- (void)startTimer:(CGFloat)time {
    if (nil == _timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(timerEndAction:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    if (nil != _timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - Setter or Getter

- (XXArrowTipsViewConfigs *)viewConfigs {
    if (!_viewConfigs) {
        _viewConfigs = ({
            XXArrowTipsViewConfigs *configs = [[XXArrowTipsViewConfigs alloc] init];
            configs;
        });
    }
    return _viewConfigs;
}

@end

@implementation XXArrowTipsViewConfigs

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.marginEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
        self.gradientColors = @[kGradientStartColor, kGradientEndColor];
        self.textFont = [UIFont systemFontOfSize:15];
        self.textColor = [UIColor whiteColor];
        self.cornerRadius = 4.0f;
    }
    return self;
}

@end
