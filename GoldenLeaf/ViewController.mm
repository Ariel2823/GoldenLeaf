//
//  ViewController.m
//  GoldenLeaf
//
//  Created by lancemao on 7/31/15.
//  Copyright (c) 2015 lancemao. All rights reserved.
//

#import "ViewController.h"
#import "FumarIOS2.h"

@interface ViewController ()
{
    IBOutlet UIView* view1;
    IBOutlet UIView* view2;
    IBOutlet UIView* view3;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setBorder:view1];
    [self setBorder:view2];
    [self setBorder:view3];
    
    [self testImage];
}

- (void)setBorder:(UIView*)v {
    v.layer.borderWidth=1;
    v.layer.borderColor = [UIColor blackColor].CGColor;
    v.layer.cornerRadius = 5;
    v.layer.masksToBounds = YES;
}

- (void)testImage
{
    
    NSLog(@"ver:%@",fuma_Bar2D_GetVersion());
    
    
    
    NSURL *url=[NSURL URLWithString:@"http://115.29.39.16/1.png"];
    
    UIImage *imgFromUrl =[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:url]];
    
    CGSize sz = [imgFromUrl size];
    int w = sz.width;
    int h = sz.height;
    
    
    
    //unsigned char * pData = (unsigned char *)malloc(w*h*4);
    
    //[ImageHelper convertUIImageToBitmapRGBA8:imgFromUrl retBut:pData];
    
    
    
    
    fuma_Bar2D_InitLib(w, h, false, false);
    //fuma_Bar2D_InitLib(w, h, false, false);
    
    char sn[100];
    
    for (int k=0; k<1; k++)
    {
        CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
        
        // do something you want to measure
        fuma_Bar2D_DoMatch(imgFromUrl, sn);
        
        CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
        NSLog(@"[%d], operation took %2.5f seconds", k, end-start);
        
        [NSThread sleepForTimeInterval:0.01f];
    }
    
    //fuma_Bar2D_DoMatch(pData, sn);
    
    NSString *astring = [NSString stringWithFormat:@"%s", sn];
    
    NSLog(@"sn:%@",astring);
    
    fuma_Bar2D_DestroyLib( );
    
    
    //free(pData);
    
    
    
    
}

@end
