//
//  LoginViewController.m
//  GoldenLeaf
//
//  Created by lancemao on 8/30/15.
//  Copyright (c) 2015 lancemao. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"

@implementation LoginViewController

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)login:(id)sender {
    NSLog(@"start loggin in...");
}

- (IBAction)registerUser:(id)sender {
    RegisterViewController* vc = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
