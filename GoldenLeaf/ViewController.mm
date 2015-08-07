//
//  ViewController.m
//  GoldenLeaf
//
//  Created by lancemao on 7/31/15.
//  Copyright (c) 2015 lancemao. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "ViewController.h"
#import "FumarIOS2.h"

@interface ViewController ()
{
    IBOutlet UIView* _tabBar;
    
    IBOutlet UIView* view1;
    IBOutlet UIView* view2;
    IBOutlet UIView* view3;
    
    UIView* _camera;
    UILabel* _snLabel;
    IBOutlet UIView* _about;
    
    AVCaptureSession *session;
}
@end

@implementation ViewController

static BOOL first = YES;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setBorder:view1];
    [self setBorder:view2];
    [self setBorder:view3];
    
//    [self testImage];
}

- (void)viewDidAppear:(BOOL)animated {
    float w = self.view.frame.size.width;
    float h = self.view.frame.size.height;
    float th = _tabBar.frame.size.height;
    _camera = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h - th)];
    _snLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 150, 300, 30)];
    _snLabel.text = @"sn:";
    _snLabel.textColor = [UIColor blackColor];
    [self.view addSubview:_camera];
    [self.view addSubview:_snLabel];
    _camera.hidden = YES;
    _snLabel.hidden = YES;
}

- (void)setBorder:(UIView*)v {
    v.layer.borderWidth=1;
    v.layer.borderColor = [UIColor blackColor].CGColor;
    v.layer.cornerRadius = 5;
    v.layer.masksToBounds = YES;
}

- (IBAction)product:(id)sender {
    _about.hidden = YES;
    [self stopSession];
}

- (IBAction)activity:(id)sender {
    _about.hidden = YES;
    [self stopSession];
}

- (IBAction)scan:(id)sender {
    _about.hidden = YES;
    [self startCaptureSession];
    _camera.hidden = NO;
    _snLabel.hidden = NO;
}

- (IBAction)mine:(id)sender {
    _about.hidden = YES;
    [self stopSession];
}

- (IBAction)about:(id)sender {
    [self stopSession];
    _about.hidden = NO;
}

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
    
    
    
    
}

@end
