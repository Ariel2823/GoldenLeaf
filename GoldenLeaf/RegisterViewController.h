//
//  RegisterViewController.h
//  GoldenLeaf
//
//  Created by lancemao on 8/30/15.
//  Copyright (c) 2015 lancemao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController <NSXMLParserDelegate>
{
    __weak IBOutlet UITextField* tfUserName;
    __weak IBOutlet UITextField* tfPwd;
    __weak IBOutlet UITextField* tfPwdAgain;
    __weak IBOutlet UITextField* tfPhoneNo;
    __weak IBOutlet UITextField* tfVCode;
}
@end
