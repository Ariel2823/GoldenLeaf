//
//  ViewController.m
//  GoldenLeaf
//
//  Created by lancemao on 7/31/15.
//  Copyright (c) 2015 lancemao. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "AFNetworking.h"
#import "Const.h"
#import "ViewController.h"
#if !TARGET_IPHONE_SIMULATOR
#import "FumarIOS2.h"
#endif

#import "LoginViewController.h"
#import "WebViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
{
    IBOutlet UIView* _tabBar;
    IBOutlet UIView* _popup;
    IBOutlet UITableView* _popTable;
    NSMutableArray* _popMenuTexts;
    BOOL _readingMenuBuf;
    NSMutableString* _popMenuURLBuffer;
    NSMutableArray* _popMenuURLs;
    NSString* _productURL;
    NSString* _activityURL;
    NSString* _curXMLTag;
    
    IBOutlet UIView* view1;
    IBOutlet UIView* view2;
    IBOutlet UIView* view3;
    
    IBOutlet UIWebView* _webView;
    
    IBOutlet UIView* _cameraContainer;
    IBOutlet UIView* _camera;
    IBOutlet UIButton* _album;
    IBOutlet UILabel* _snLabel;
    IBOutlet UIImageView* _testIV;
    
    IBOutlet UIView* _about;
    IBOutlet UIView* _loginHint;
    IBOutlet UIButton* _loginButton;
    
    AVCaptureSession *session;
    
    NSMutableString* _announcementBuffer;
    NSString* _announcementURL;
    
    NSMutableString* _privateLetterBuffer;
    NSString* _privateLetterURL;
    
    NSMutableString* _myInfoBuffer;
    NSString* _myInfoURL;
}
@end

@implementation ViewController

static bool first = true;
static bool separateWebView = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView.delegate = self;
    
    _popMenuTexts = [NSMutableArray new];
    
    _popMenuURLBuffer = [NSMutableString new];
    _popMenuURLs = [NSMutableArray new];
    _announcementBuffer = [NSMutableString new];
    _privateLetterBuffer = [NSMutableString new];
    _myInfoBuffer = [NSMutableString new];
    
    [self setBorder:view1];
    [self setBorder:view2];
    [self setBorder:view3];
    
    _album.layer.borderWidth=1;
    _album.layer.borderColor = [UIColor whiteColor].CGColor;
    _album.layer.cornerRadius = 3;
    _album.layer.masksToBounds = YES;
    
    _popup.hidden = YES;
//    [self testImage];
    
    NSString *soapMessage =
    [NSString stringWithFormat:
     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
     "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
     "<soap12:Body>"
     "<GetMenu xmlns=\"http://tempuri.org/\" />"
     "</soap12:Body>"
     "</soap12:Envelope>"
     ];
    [self soap:soapMessage];
    
    // this will set Mine as the first tab
    [self hideAll];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* userName = [userDefaults objectForKey:@"userName"];
    _loginHint.hidden = userName != nil;
    [_loginButton setTitle:(_loginHint.hidden ? @"登出" : @"登录") forState:UIControlStateNormal];
    lock = false;
    
    NSString *announcement =
    [NSString stringWithFormat:
     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
     "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
     "<soap12:Body>"
     "<GetAnnouncement xmlns=\"http://tempuri.org/\" >"
     "</GetAnnouncement>"
     "</soap12:Body>"
     "</soap12:Envelope>"
     ];
    [self soap:announcement];
    
    NSString *soapMessage =
    [NSString stringWithFormat:
     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
     "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
     "<soap12:Body>"
     "<GetPrivateLetter xmlns=\"http://tempuri.org/\" >"
     "<user_name>"
     "%@"
     "</user_name>"
     "</GetPrivateLetter>"
     "</soap12:Body>"
     "</soap12:Envelope>", userName
     ];
    [self soap:soapMessage];
    
    NSString *myInfo =
    [NSString stringWithFormat:
     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
     "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
     "<soap12:Body>"
     "<GetUserDetails xmlns=\"http://tempuri.org/\" >"
     "</GetUserDetails>"
     "</soap12:Body>"
     "</soap12:Envelope>"
     ];
    [self soap:myInfo];
    
    NSString* url = ((AppDelegate*)[UIApplication sharedApplication].delegate).urlAfterLogin;
    if (url) {
        lock = false;
        [self hideAll];
        [self gotoWebView:url];
    }
}

- (void)setBorder:(UIView*)v {
    v.layer.borderWidth=1;
    v.layer.borderColor = [UIColor blackColor].CGColor;
    v.layer.cornerRadius = 5;
    v.layer.masksToBounds = YES;
}

- (void)hideAll {
    _cameraContainer.hidden = YES;
    _camera.hidden = YES;
    _snLabel.hidden = YES;
    _webView.hidden = YES;
    [self stopSession];
    _about.hidden = YES;
}

- (IBAction)topLeft:(id)sender {
    _popup.hidden = !_popup.hidden;
}

- (IBAction)product:(id)sender {
    [self hideAll];
    _webView.hidden = NO;
    NSURL *url = [NSURL URLWithString:_productURL];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)activity:(id)sender {
    [self hideAll];
    _webView.hidden = NO;
    NSURL *url = [NSURL URLWithString:_activityURL];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (IBAction)scan:(id)sender {
    [self hideAll];
    [self startCaptureSession];
    _cameraContainer.hidden = NO;
    _camera.hidden = NO;
    _snLabel.hidden = NO;
    lock = false;
}

- (IBAction)mine:(id)sender {
    [self hideAll];
}

- (IBAction)about:(id)sender {
    [self hideAll];
    _about.hidden = NO;
}

- (IBAction)gotoAnnouncement:(id)sender {
    lock = false;
    [self hideAll];
    if (_announcementURL)
        [self gotoWebView:_announcementURL];
}

- (IBAction)gotoPrivateLetter:(id)sender {
    lock = false;
    [self hideAll];
    if (_privateLetterURL)
        [self gotoWebView:_privateLetterURL];
}

- (IBAction)gotoMyInfo:(id)sender {
    lock = false;
    [self hideAll];
    if (_myInfoURL)
        [self gotoWebView:_myInfoURL];
}

- (IBAction)login:(id)sender {
    if (_loginHint.hidden) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"userName"];
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        _loginHint.hidden = NO;
    } else {
        LoginViewController* vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)albumClicked:(id)sender {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;   // 设置委托
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

//完成拍照
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil)
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
//    image = [self fixOrientation:image];
    
    int swidth = image.size.width;
    int sheight = image.size.height;
    int width = 480;
    int height = 360;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel    = 4;
    size_t bytesPerRow      = (width * bitsPerComponent * bytesPerPixel + 7) / 8;
    size_t dataSize         = bytesPerRow * height;
    
    unsigned char *mData = (unsigned char*)malloc(dataSize);
    memset(mData, 0, dataSize);
    
    CGContextRef mContext = CGBitmapContextCreate(mData, width, height,
                                     bitsPerComponent,
                                     bytesPerRow, colorSpace,
                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // fill with black
    CGRect myRect = {0, 0, 480, 360};
    CGContextSetRGBFillColor(mContext, 0, 0, 1, 1);
    CGContextSetRGBStrokeColor(mContext, 0, 0, 0, 1);
    CGContextSaveGState(mContext);
    CGContextFillRect(mContext, myRect);
    CGContextRestoreGState(mContext);
    
    // draw image
    CGContextDrawImage(mContext, CGRectMake(50, 50, swidth, sheight), image.CGImage);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(mContext);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    
     _testIV.image = result;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self testImage:result];
    });
}

//用户取消拍照
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Popup
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _popMenuURLs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CMainCell = @"CMainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CMainCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier: CMainCell];
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.22 alpha:1];
        float cw = tableView.frame.size.width;
        CGRect f = CGRectMake(8, 8, cw - 16, 42);
        UILabel* l = [[UILabel alloc] initWithFrame:f];
        l.layer.borderWidth=1;
        l.layer.borderColor = [UIColor colorWithWhite:0.39 alpha:1].CGColor;
        l.layer.cornerRadius = 3;
        l.layer.masksToBounds = YES;
        l.backgroundColor = [UIColor colorWithWhite:0.39 alpha:1];
        l.textAlignment = NSTextAlignmentCenter;
        l.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:l];
    }
    
    UILabel* l = (UILabel*)cell.contentView.subviews[0];
    l.text = _popMenuTexts[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* url = _popMenuURLs[indexPath.row];
    _webView.hidden = NO;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    _popup.hidden = YES;
}

#pragma mark Camera
- (void)startCaptureSession
{
    if (!session) {
        NSError *error = nil;
        
        // Create the session
        session = [[AVCaptureSession alloc] init];
        
        // Configure the session to produce lower resolution video frames, if your
        // processing algorithm can cope. We'll specify medium quality for the
        // chosen device.
        session.sessionPreset = AVCaptureSessionPresetMedium;
        
        // Find a suitable AVCaptureDevice
        AVCaptureDevice *device = [AVCaptureDevice
                                   defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // Create a device input with the device and add it to the session.
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                            error:&error];
        if (!input) {
            // Handling the error appropriately.
            return;
        }
        [session addInput:input];
        
        // Create a VideoDataOutput and add it to the session
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [session addOutput:output];
        
        // Configure your output.
        dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
        [output setSampleBufferDelegate:self queue:queue];
        
        // Specify the pixel format
        output.videoSettings =
        [NSDictionary dictionaryWithObject:
         [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                    forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        
        AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.frame = _camera.bounds;
        [_camera.layer addSublayer:previewLayer];
    }
    
    // Start the session running to start the flow of data
    [session startRunning];
}

- (void)stopSession {
    [session stopRunning];
    _cameraContainer.hidden = YES;
    _camera.hidden = YES;
    _snLabel.hidden = YES;
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    [self testImage:image];
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

- (void)testImage:(UIImage*)image;
{
#if !TARGET_IPHONE_SIMULATOR
//    NSLog(@"ver:%@",fuma_Bar2D_GetVersion());
    
    if (!image) {
        NSURL *url=[NSURL URLWithString:@"http://115.29.39.16/1.png"];
        image =[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:url]];
    }
    
    CGSize sz = [image size];
    int w = sz.width;
    int h = sz.height;
    
    
    
    //unsigned char * pData = (unsigned char *)malloc(w*h*4);
    
    //[ImageHelper convertUIImageToBitmapRGBA8:imgFromUrl retBut:pData];
    
    
    
    if (first) {
        fuma_Bar2D_InitLib(w, h, false, false);
        first = NO;
    }
    //fuma_Bar2D_InitLib(w, h, false, false);
    
    char sn[100];
    
    for (int k=0; k<1; k++)
    {
//        CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
        
        // do something you want to measure
        fuma_Bar2D_DoMatch(image, sn);
        
//        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
//        NSLog(@"[%d], operation took %2.5f seconds", k, end-start);
        
        [NSThread sleepForTimeInterval:0.01f];
    }
    
    //fuma_Bar2D_DoMatch(pData, sn);
    
    NSString *astring = [NSString stringWithFormat:@"%s", sn];
    
    if (astring.length > 0)
        NSLog(@"sn: %s",sn);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _snLabel.text = astring;
        if (astring.length > 0) {
            NSString *soapMessage =
            [NSString stringWithFormat:
             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
             "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
             "<soap12:Body>"
             "<GetBarCodeUrl xmlns=\"http://tempuri.org/\" >"
             "<tcode>"
             "%@"
             "</tcode>"
             "</GetBarCodeUrl>"
             "</soap12:Body>"
             "</soap12:Envelope>", astring
             ];
            [self soap:soapMessage];
        }
    });
    
//    fuma_Bar2D_DestroyLib( );
    
    
    //free(pData);
    
#endif
    
    
}

#pragma mark WebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"Web page loaded");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Web page failed to load: %@", error.description);
}

#pragma mark XMLParser Delegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    NSLog(@"发现节点:%@", elementName);
    _curXMLTag = elementName;
    if ([elementName isEqualToString:@"GetMenuResult"]) {
        _readingMenuBuf = YES;
        _popMenuURLBuffer = [NSMutableString new];
    } else if ([_curXMLTag isEqualToString:@"GetAnnouncement"]) {
        _announcementBuffer = [NSMutableString new];
    } else if ([_curXMLTag isEqualToString:@"GetPrivateLetterResult"]) {
        _privateLetterBuffer = [NSMutableString new];
    } else if ([_curXMLTag isEqualToString:@"GetUserDetails"]) {
        _myInfoBuffer = [NSMutableString new];
    }
}

/* 当解析器找到开始标记和结束标记之间的字符时，调用这个方法解析当前节点的所有字符 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"found character: %@", string);
    if (_readingMenuBuf) {
        [_popMenuURLBuffer appendString:string];
    } else if ([_curXMLTag isEqualToString:@"GetBarCodeUrlResult"]) {
        [self gotoWebView:string];
    } else if ([_curXMLTag isEqualToString:@"GetAnnouncementResult"]) {
        [_announcementBuffer appendString:string];
    } else if ([_curXMLTag isEqualToString:@"GetPrivateLetterResult"]) {
        [_privateLetterBuffer appendString:string];
    } else if ([_curXMLTag isEqualToString:@"GetUserDetailsResult"]) {
        [_myInfoBuffer appendString:string];
    }
}

/* 当解析器对象遇到xml的结束标记时，调用这个方法完成解析该节点 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"GetMenuResult"]) {
        _readingMenuBuf = NO;
        [_popMenuURLs removeAllObjects];
        [_popMenuTexts removeAllObjects];
        NSLog(@"%@", _popMenuURLBuffer);
        NSError* e;
        NSData* data = [_popMenuURLBuffer dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&e];
        for (NSDictionary* item in result) {
            NSString* name = [item[@"MenuName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString* menuName = item[@"MenuName"];
            [_popMenuTexts addObject:menuName];
            NSString* url = item[@"MenuUrl"];
            [_popMenuURLs addObject:url];
            if ([name isEqualToString:@"产品中心"]) {
                _productURL = url;
            } else if ([name isEqualToString:@"活动专区"]) {
                _activityURL = url;
            }
        }
        [_popTable reloadData];
        
        // previously we go to product when first appear, now we go to MINE instead
        // so comment out the following lines
//        if (_popMenuURLs && _popMenuURLs.count > 0)
//            [self gotoWebView:_popMenuURLs[0]];
    } else if ([_curXMLTag isEqualToString:@"GetAnnouncementResult"]) {
        _announcementURL = _announcementBuffer;
    } else if ([_curXMLTag isEqualToString:@"GetPrivateLetterResult"]) {
        NSError* e;
        NSData* data = [_privateLetterBuffer dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&e];
        if (result && result.count > 0) {
            _privateLetterURL = result[0][@"MenuUrl"];
        }
    } else if ([_curXMLTag isEqualToString:@"GetUserDetailsResult"]) {
        NSError* e;
        NSData* data = [_myInfoBuffer dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&e];
        if (result && result.count > 0) {
            _myInfoURL = result[0][@"MenuUrl"];
        }
    }
}

#pragma mark SOAP
- (void)soap :(NSString*)soapMessage {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

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
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
    
    [operation start];
}

static bool lock = false;
- (void)gotoWebView:(NSString*)url {
    if (!lock) {
        lock = true;
        if (separateWebView) {
            WebViewController* vc = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle]];
            vc.url = url;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            [self hideAll];
            _webView.hidden = NO;
            NSURL *bcurl = [NSURL URLWithString:url];
            [_webView loadRequest:[NSURLRequest requestWithURL:bcurl]];

        }
    }
}
@end
