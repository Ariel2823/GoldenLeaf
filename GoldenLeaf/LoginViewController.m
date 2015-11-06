//
//  LoginViewController.m
//  GoldenLeaf
//
//  Created by lancemao on 8/30/15.
//  Copyright (c) 2015 lancemao. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "AFNetworking.h"
#import "Const.h"
#import "AppDelegate.h"

@interface LoginViewController ()
{
    NSString* _userName;
    NSString* _pwd;
}
@end

@implementation LoginViewController

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)login:(id)sender {
    NSLog(@"start loggin in...");
    
    _userName = [AppDelegate isEmptyString:tfUserName.text] ? @"18602897592" : tfUserName.text;
    _pwd = [AppDelegate isEmptyString:tfPwd.text] ? @"123456" : tfPwd.text;
    NSString *soapMessage =
    [NSString stringWithFormat:
     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
     "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
     "<soap12:Body>"
     "<Getlogins xmlns=\"http://tempuri.org/\" >"
        "<usernmae>"
            "%@"
        "</usernmae>"
        "<pw>"
            "%@"
        "</pw>"
     "</Getlogins>"
     "</soap12:Body>"
     "</soap12:Envelope>", _userName, _pwd
     ];
    
    NSURL *url = [NSURL URLWithString:@HOME];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    [request addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSXMLParser* parser = responseObject;
        parser.delegate = self;
        [parser parse];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"登录失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [view show];
    }];
    
    [operation start];
}

- (IBAction)registerUser:(id)sender {
    RegisterViewController* vc = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark XMLParser Delegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    NSLog(@"发现节点:%@", elementName);
}

/* 当解析器找到开始标记和结束标记之间的字符时，调用这个方法解析当前节点的所有字符 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"found characters:%@", string);
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([string isEqualToString:@"true"]) {
        NSLog(@"Login success");
        [userDefaults setObject:_userName forKey:@"userName"];
        [self back:nil];
    } else {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"登录失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [view show];
    }
    [userDefaults synchronize];
}

/* 当解析器对象遇到xml的结束标记时，调用这个方法完成解析该节点 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
}

@end
