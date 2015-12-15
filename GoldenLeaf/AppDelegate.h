//
//  AppDelegate.h
//  GoldenLeaf
//
//  Created by lancemao on 7/31/15.
//  Copyright (c) 2015 lancemao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Const.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *deviceToken;
@property (strong, nonatomic) NSString *urlAfterLogin;

+ (BOOL)isEmptyString:(NSString *)string;

@end

