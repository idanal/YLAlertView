YLAlertView for iOS

Import:

    pod 'YLAlertView', :git=>'https://github.com/idanal/YLAlertView.git'

Usage (Almost the same as UIAlertController):


    YLAlertView *alert = [YLAlertView alertWithTitle:@"title" message:@"this is a message in alert view"];
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
    [alert show];
    //[alert showAsSheet];
