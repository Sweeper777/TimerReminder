# 介绍
各种引导页需要使用渐变色箭头的提示View。
XXArrowTipsView提供可配置的功能，方便开发者配置展示

# 使用方法

1. 传入需要显示箭头view的父view
2. 传入箭头view中箭头所指向的点位置
3. 箭头view的配置选项
 
+ (instancetype)showInSuperView:(UIView *)superView point:(CGPoint)point configs:(XXArrowTipsViewConfigs *)configs

## 配置选项

目前开放的可配置选项:

1. marginEdgeInsets  // 中间文字离边缘的间距(默认为（10, 10, 10, 10）);
2. titleText // 需要显示的文本(不能为空);
3. gradientColors // 渐变的颜色
4. textFont// 文本字体大小
5. textColor // 文本颜色
6. cornerRadius // 整个view的cornerRadius
7. arrowDirection// 箭头方向

## 操作

### 启动显示定时器

- (void)startShowTimer:(CGFloat)time block:(showTimerEndBlock)block

### 点击View的回调处理

typedef void(^pressArrowTipsViewBlock)(XXArrowTipsView *view)


