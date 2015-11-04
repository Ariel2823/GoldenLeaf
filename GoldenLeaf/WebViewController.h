//
//  WebViewController.h
//  GoldenLeaf
//
//  Created by Lance Mao on 11/4/15.
//  Copyright © 2015 lancemao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
{
    IBOutlet UIWebView* webView;
}

@property (nonatomic, strong) NSString* url;

@end
