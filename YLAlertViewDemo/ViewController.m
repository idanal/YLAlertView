//
//  ViewController.m
//
//
//  Created by yunlin.luo on 2018/1/4.
//  Copyright © 2018年 lyl. All rights reserved.
//

#import "ViewController.h"
#import "YLAlertView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    YLAlertView *alert = [YLAlertView alertWithTitle:@"title" message:@"this is a message in alert view 1 2 3 4 5 6 7 8 9 213 4456 7575889 7898798 79797978"];
    [alert addAction:[YLAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(YLAlertAction * _Nonnull action) {
        NSLog(@"cancel");
    }]];
    YLAlertAction *ok = [alert addAction:[YLAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(YLAlertAction * _Nonnull action) {
        NSLog(@"ok");
    }]];
    ok.enabled = NO;
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Text filed";
    }];
    CGPoint pos = [touches.anyObject locationInView:self.view];
    if (pos.y < 300) {
        [alert show];
    } else {
        [alert showAsSheet];
    }
//    ok.enabled = NO;
}

@end

