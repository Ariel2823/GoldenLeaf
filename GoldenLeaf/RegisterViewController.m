//
//  RegisterViewController.m
//  GoldenLeaf
//
//  Created by lancemao on 8/30/15.
//  Copyright (c) 2015 lancemao. All rights reserved.
//

#import "AFNetworking.h"
#import "RegisterViewController.h"
#import "AppDelegate.h"

@interface RegisterViewController ()
{
    NSString* _curXMLTag;
    NSString* _userName;
    NSMutableString* _responseBuffer;
}
@end

@implementation RegisterViewController

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)registerClicked:(id)sender {
    if ([AppDelegate isEmptyString:tfUserName.text]) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"用户名不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [view show];
        return;
    }
    
    if ([AppDelegate isEmptyString:tfPwd.text] || [AppDelegate isEmptyString:tfPwdAgain.text]) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [view show];
        return;
    }
    
    if (![tfPwdAgain.text isEqualToString:tfPwd.text]) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"密码不匹配" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [view show];
        return;
    }
    
    if ([AppDelegate isEmptyString:tfVCode.text]) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"验证码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [view show];
        return;
    }
    
    _userName = tfUserName.text;
    
    NSString* userName = tfUserName.text;
    NSString* pwd = tfPwd.text;
    NSString* vCode = tfVCode.text;
    
    NSString* dt = ((AppDelegate*)[UIApplication sharedApplication].delegate).deviceToken;
    
    NSString *soapMessage =
    [NSString stringWithFormat:
     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
     "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
     "<soap12:Body>"
     "<RegisterLogin xmlns=\"http://tempuri.org/\" >"
     "<username>"
     "%@"
     "</username>"
     "<pw>"
     "%@"
     "</pw>"
     "<tag>"
     "%@"
     "</tag>"
     "<code>"
     "%@"
     "</code>"
     "</RegisterLogin>"
     "</soap12:Body>"
     "</soap12:Envelope>", userName, pwd, dt, vCode
     ];
    
    [APService setTags:[NSSet setWithObjects:_userName, nil] alias:_userName callbackSelector:nil object:nil];
    
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
    }];
    
    [operation start];
}

- (IBAction)getVerificationCodeClicked:(id)sender {
    if ([AppDelegate isEmptyString:tfUserName.text]) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"手机号码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [view show];
        return;
    }

    NSString* phoneNo = tfUserName.text;

    NSString *soapMessage =
    [NSString stringWithFormat:
     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
     "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
     "<soap12:Body>"
     "<GetVerificationCode xmlns=\"http://tempuri.org/\" >"
     "<mobileNum>"
     "%@"
     "</mobileNum>"
     "</GetVerificationCode>"
     "</soap12:Body>"
     "</soap12:Envelope>", phoneNo
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
    }];
    
    [operation start];
}

#pragma mark XMLParser Delegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    NSLog(@"发现节点:%@", elementName);
    _responseBuffer = [NSMutableString new];
    _curXMLTag = elementName;
}

/* 当解析器找到开始标记和结束标记之间的字符时，调用这个方法解析当前节点的所有字符 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"found characters:%@", string);
    [_responseBuffer appendString:string];
    
    if ([_curXMLTag isEqualToString:@"GetVerificationCodeResult"]) {
        if ([string isEqualToString:@"0"] || [string isEqualToString:@"false"]) {
            UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"发送验证码失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [view show];
        } else {
            UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"发送验证码成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [view show];
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([string isEqualToString:@"-1"] || [string isEqualToString:@"false"] || [string isEqualToString:@"2"]) {
            UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"注册失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [view show];
        } else if ([string isEqualToString:@"0"]) {
            UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"" message:@"用户已经注册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [view show];
        } else {
            NSLog(@"Register success");
            [userDefaults setObject:_userName forKey:@"userName"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        [userDefaults synchronize];
    }
}

/* 当解析器对象遇到xml的结束标记时，调用这个方法完成解析该节点 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"RegisterLoginResult"]) {
        NSLog(@"direct URL: %@", _responseBuffer);
        ((AppDelegate*)[UIApplication sharedApplication].delegate).urlAfterLogin = _responseBuffer;
    }
}

@end
