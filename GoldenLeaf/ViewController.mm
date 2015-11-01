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

@interface ViewController ()
{
    IBOutlet UIView* _tabBar;
    IBOutlet UIView* _popup;
    IBOutlet UITableView* _popTable;
    NSArray* _popMenuTexts;
    BOOL _readingMenuBuf;
    NSMutableString* _popMenuURLBuffer;
    NSMutableArray* _popMenuURLs;
    NSString* _productURL;
    NSString* _activityURL;
    
    IBOutlet UIView* view1;
    IBOutlet UIView* view2;
    IBOutlet UIView* view3;
    
    IBOutlet UIWebView* _webView;
    
    IBOutlet UIView* _camera;
    IBOutlet UILabel* _snLabel;
    
    IBOutlet UIView* _about;
    
    AVCaptureSession *session;
}
@end

@implementation ViewController

static bool first = true;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView.delegate = self;
    
    _popMenuTexts = @[@"产品中心",
                      @"积分商城",
                      @"中烟风采",
                      @"风土人情",
                      @"品牌故事",
                      @"活动专区",
                      @"会员专区",
                      @"防伪验证",
                      @"问卷调查",
                      @"留言反馈"];
    
    _popMenuURLBuffer = [NSMutableString new];
    _popMenuURLs = [NSMutableArray new];
    
    [self setBorder:view1];
    [self setBorder:view2];
    [self setBorder:view3];
    
    _popup.hidden = YES;
//    [self testImage];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *soapMessage =
    [NSString stringWithFormat:
     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
     "<soap12:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
     "<soap12:Body>"
     "<GetMenu xmlns=\"http://tempuri.org/\" />"
     "</soap12:Body>"
     "</soap12:Envelope>"
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

- (void)setBorder:(UIView*)v {
    v.layer.borderWidth=1;
    v.layer.borderColor = [UIColor blackColor].CGColor;
    v.layer.cornerRadius = 5;
    v.layer.masksToBounds = YES;
}

- (void)hideAll {
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
    _camera.hidden = NO;
    _snLabel.hidden = NO;
}

- (IBAction)mine:(id)sender {
    [self hideAll];
}

- (IBAction)about:(id)sender {
    [self hideAll];
    _about.hidden = NO;
}

- (IBAction)login:(id)sender {
    LoginViewController* vc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
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
        previewLayer.frame = _camera.bounds;
        [_camera.layer addSublayer:previewLayer];
    }
    
    // Start the session running to start the flow of data
    [session startRunning];
}

- (void)stopSession {
    [session stopRunning];
    _camera.hidden = YES;
    _snLabel.hidden = YES;
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
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
    NSLog(@"ver:%@",fuma_Bar2D_GetVersion());
    
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
        CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
        
        // do something you want to measure
        fuma_Bar2D_DoMatch(image, sn);
        
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
        NSLog(@"[%d], operation took %2.5f seconds", k, end-start);
        
        [NSThread sleepForTimeInterval:0.01f];
    }
    
    //fuma_Bar2D_DoMatch(pData, sn);
    
    NSString *astring = [NSString stringWithFormat:@"sn: %s", sn];
    
    NSLog(@"%@",astring);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _snLabel.text = astring;
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
    if ([elementName isEqualToString:@"GetMenuResult"]) {
        _readingMenuBuf = YES;
        _popMenuURLBuffer = [NSMutableString new];
    }
}

/* 当解析器找到开始标记和结束标记之间的字符时，调用这个方法解析当前节点的所有字符 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_readingMenuBuf) {
        [_popMenuURLBuffer appendString:string];
    }
}

/* 当解析器对象遇到xml的结束标记时，调用这个方法完成解析该节点 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"GetMenuResult"]) {
        [_popMenuURLs removeAllObjects];
        NSLog(@"%@", _popMenuURLBuffer);
        NSError* e;
        NSData* data = [_popMenuURLBuffer dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&e];
        for (NSDictionary* item in result) {
            NSString* name = [item[@"MenuName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString* url = item[@"MenuUrl"];
            [_popMenuURLs addObject:url];
            if ([name isEqualToString:@"产品中心"]) {
                _productURL = url;
            } else if ([name isEqualToString:@"活动专区"]) {
                _activityURL = url;
            }
        }
        [_popTable reloadData];
    }
}

@end
