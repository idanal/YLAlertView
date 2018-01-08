//
//  YLAlertView.h
//
//
//  Created by yunlin.luo on on 2018/1/4.
//  Copyright © 2018年 lyl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YLAlertAction;

NS_ASSUME_NONNULL_BEGIN

/**
 Alert View
 */
@interface YLAlertView : UIView
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;
@property (nonatomic, readonly) NSArray<YLAlertAction *> *actions;
@property (nullable, nonatomic, readonly) NSArray<UITextField *> *textFields;

/**
 Create instance

 @param title Title
 @param message Message
 @return Instance
 */
+ (instancetype)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

/**
 Add a action

 @param action Action
 @return Action instance
 */
- (YLAlertAction *)addAction:(YLAlertAction *)action;

/**
 Add a text field. Only available for alert

 @param configurationHandler Configuration Handler
 */
- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;

/**
 Show as alert
 */
- (void)show;

/**
 Show as action sheet
 */
- (void)showAsSheet;

/**
 Dismiss
 */
- (void)dismiss;

@end


/**
 Alert Action
 */
@interface YLAlertAction : NSObject

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(UIAlertActionStyle)style handler:(void (^ __nullable)(YLAlertAction *action))handler;

@property (nullable, nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nullable, nonatomic, copy) void (^handler)(YLAlertAction *action);

@end

NS_ASSUME_NONNULL_END
