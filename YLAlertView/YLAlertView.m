//
//  YLAlertView.m
//  
//
//  Created by yunlin.luo on on 2018/1/4.
//  Copyright © 2018年 lyl. All rights reserved.
//

#import "YLAlertView.h"

#define _YLAlertBorderColor [UIColor colorWithRed:0xd1/255.0 green:0xd1/255.0 blue:0xd1/255.0 alpha:1.0]

@interface _YLAlertButton : UIButton
@property (nonatomic, strong) YLAlertAction *alertAction;
@property (nonatomic, weak) CAShapeLayer *lineLayer;
@property (nonatomic) BOOL enableLineLayer;

+ (instancetype)buttonWithAction:(YLAlertAction *)alertAction;

@end

@implementation _YLAlertButton

+ (instancetype)buttonWithAction:(YLAlertAction *)alertAction {
    _YLAlertButton *btn = [_YLAlertButton buttonWithType:UIButtonTypeSystem];
    btn.alertAction = alertAction;
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [btn setTitle:alertAction.title forState:UIControlStateNormal];
    switch (alertAction.style) {
        case UIAlertActionStyleCancel:
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            break;
        case UIAlertActionStyleDestructive:
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            break;
        case UIAlertActionStyleDefault:
        default:
            //default color
            break;
    }
    btn.enabled = alertAction.enabled;
    [alertAction addObserver:btn forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
    return btn;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqual:@"enabled"]) {
        BOOL enabled = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        self.enabled = enabled;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_enableLineLayer) {
        return;
    }
    
    if (!_lineLayer) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.strokeColor = _YLAlertBorderColor.CGColor;
        layer.lineWidth = 0.5;
        [self.layer addSublayer:layer];
        self.lineLayer = layer;
    }
    CAShapeLayer *layer = _lineLayer;
    layer.frame = self.bounds;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, self.bounds.size.width, 0);
    CGPathMoveToPoint(path, NULL, self.bounds.size.width, 0);
    CGPathAddLineToPoint(path, NULL, self.bounds.size.width, self.bounds.size.height);
    layer.path = path;
    CGPathRelease(path);
}

- (void)dealloc {
    [self.alertAction removeObserver:self forKeyPath:@"enabled"];
}

@end


@interface YLAlertView () <CAAnimationDelegate> {
    __weak UIView *_maskView;
}
@property (nonatomic, strong) NSMutableArray *buttons;
@end

@implementation YLAlertView

+ (instancetype)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message {
    return [[self alloc] initWithTitle:title message:message];
}

- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message {
    self = [super initWithFrame:CGRectMake(0, 0, 100, 100)];
    if (self) {
        _title = title;
        _message = message;
        _buttons = [NSMutableArray new];
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 10;
    }
    return self;
}

- (YLAlertAction *)addAction:(YLAlertAction *)action {
    if (_actions) {
        NSMutableArray *a = [_actions mutableCopy];
        [a addObject:action];
        _actions = [[NSArray alloc] initWithArray:a];
    } else {
        _actions = @[action];
    }
    return action;
}

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.layer.borderColor = _YLAlertBorderColor.CGColor;
    textField.layer.borderWidth = 1.0;
    if (_textFields) {
        NSMutableArray *a = [_textFields mutableCopy];
        [a addObject:textField];
        _textFields = [[NSArray alloc] initWithArray:a];
    } else {
        _textFields = @[textField];
    }
    if (configurationHandler) {
        configurationHandler(textField);
    }
}

- (void)show {
    UIWindow *win = [UIApplication sharedApplication].delegate.window;
    [win addSubview:self];
    
    UIView *maskView = [[UIView alloc] initWithFrame:win.bounds];
    maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [win insertSubview:maskView belowSubview:self];
    _maskView = maskView;
    
    UIView *vLast = nil;
    NSString *format = nil;
    //title
    {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = _title;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel);
        format = @"H:|-20-[titleLabel]-20-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        format = @"V:|-20-[titleLabel]";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        vLast = titleLabel;
    }
    //message
    if (_message) {
        UILabel *msgLabel = [[UILabel alloc] init];
        msgLabel.text = _message;
        msgLabel.numberOfLines = 0;
        msgLabel.font = [UIFont systemFontOfSize:15];
        msgLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:msgLabel];
        msgLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(msgLabel, vLast);
        format = @"H:|-20-[msgLabel]-20-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        format = [NSString stringWithFormat:@"V:[vLast]-10-[msgLabel]"];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        vLast = msgLabel;
    }
    //textfields
    for (UITextField *tf in _textFields) {
        [self addSubview:tf];
        tf.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(tf, vLast);
        format = @"H:|-20-[tf]-20-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        format = [NSString stringWithFormat:@"V:[vLast]-10-[tf(28)]"];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        vLast = tf;
    }
    //actions
    UIView *hLast = self;
    NSUInteger actCount = _actions.count;
    for (YLAlertAction *action in _actions) {
        _YLAlertButton *actButton = [_YLAlertButton buttonWithAction:action];
        actButton.enableLineLayer = YES;
        [actButton addTarget:self action:@selector(_onActionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:actButton];
        actButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(actButton, hLast, vLast);
        format = [NSString stringWithFormat:@"H:%@-0-[actButton]", hLast == self ? @"|" : @"[hLast]"];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        format = @"V:[vLast]-15-[actButton(50)]";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:actButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0/actCount constant:0]];
        [_buttons addObject:actButton];
        hLast = actButton;
    }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    if (_buttons.count > 0) {
        vLast = _buttons.lastObject;
        format = [NSString stringWithFormat:@"V:[vLast]-0-|"];
    } else {
        format = [NSString stringWithFormat:@"V:[vLast]-15-|"];
    }
    NSDictionary *views = NSDictionaryOfVariableBindings(vLast);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
    
    //center and edges
    [win addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:win attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [win addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:win attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [win addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:win attribute:NSLayoutAttributeLeading multiplier:1.0 constant:60]];
    
    //animation
    self.layer.transform = CATransform3DMakeScale(0, 0, 0);
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.duration = 0.25;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.values = @[
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],
                    ];
    anim.delegate = self;
    [self.layer addAnimation:anim forKey:nil];
}

- (void)showAsSheet {
    UIWindow *win = [UIApplication sharedApplication].delegate.window;
    [win addSubview:self];
    
    UIView *maskView = [[UIView alloc] initWithFrame:win.bounds];
    maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [win insertSubview:maskView belowSubview:self];
    _maskView = maskView;
    
    self.backgroundColor = [UIColor whiteColor];
    
    UIView *vLast = nil;
    NSString *format = nil;
    //title
    {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = _title;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel);
        format = @"H:|-20-[titleLabel]-20-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        format = @"V:|-20-[titleLabel]";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        vLast = titleLabel;
    }
    //message
    if (_message) {
        UILabel *msgLabel = [[UILabel alloc] init];
        msgLabel.text = _message;
        msgLabel.numberOfLines = 0;
        msgLabel.font = [UIFont systemFontOfSize:15];
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:msgLabel];
        msgLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(msgLabel, vLast);
        format = @"H:|-20-[msgLabel]-20-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        format = [NSString stringWithFormat:@"V:[vLast]-10-[msgLabel]"];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        vLast = msgLabel;
    }
    //actions
    NSArray *actions = [_actions sortedArrayUsingComparator:^NSComparisonResult(YLAlertAction * _Nonnull obj1, YLAlertAction * _Nonnull obj2) {
        return obj1.style == UIAlertActionStyleCancel ? NSOrderedDescending : NSOrderedAscending;
    }];
    for (YLAlertAction *action in actions) {
        _YLAlertButton *actButton = [_YLAlertButton buttonWithAction:action];
        actButton.backgroundColor = [UIColor whiteColor];
        actButton.layer.cornerRadius = 5.0;
        actButton.layer.borderWidth = 0.5;
        actButton.layer.borderColor = _YLAlertBorderColor.CGColor;
        [actButton addTarget:self action:@selector(_onActionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:actButton];
        actButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = NSDictionaryOfVariableBindings(actButton, vLast);
        format = @"H:|-20-[actButton]-20-|";
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        format = [NSString stringWithFormat:@"V:[vLast]-15-[actButton(44)]"];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
        [_buttons addObject:actButton];
        vLast = actButton;
    }
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    if (_buttons.count > 0) {
        vLast = _buttons.lastObject;
        format = [NSString stringWithFormat:@"V:[vLast]-20-|"];
    } else {
        format = [NSString stringWithFormat:@"V:[vLast]-15-|"];
    }
    NSDictionary *views = NSDictionaryOfVariableBindings(vLast);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views]];
    
    //edges
    [win addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:win attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [win addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:win attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [win addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:win attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    
    //animation
    [self layoutIfNeeded];
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.duration = 0.25;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.values = @[
                    [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, self.bounds.size.height, 0)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0, 0, 0)],
                    ];
    anim.delegate = self;
    [self.layer addAnimation:anim forKey:nil];
}

- (void)dismiss {
    [_maskView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)_onActionButtonClick:(_YLAlertButton *)sender {
    if (sender.alertAction.handler) {
        sender.alertAction.handler(sender.alertAction);
    }
    [self dismiss];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [self.layer removeAllAnimations];
        self.layer.transform = CATransform3DIdentity;
    }
}

@end


@implementation YLAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(YLAlertAction * _Nonnull))handler {
    return [[self alloc] initWithTitle:title style:style handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(YLAlertAction * _Nonnull))handler {
    self = [super init];
    if (self) {
        _title = title;
        _style = style;
        _handler = handler;
        _enabled = YES;
    }
    return self;
}

@end
