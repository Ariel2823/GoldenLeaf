//
//  FumarIOS2.h
//  FumarIOS2
//
//  Created by alex chen on 15-7-28.
//  Copyright (c) 2015年 Tony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NSString* fuma_Bar2D_GetVersion();

bool fuma_Bar2D_InitLib(int nWidth,
                        int nHeight,
                        bool bUpSideDown,
                        bool bExpand
                        );
  

bool fuma_Bar2D_DestroyLib( );


void fuma_Bar2D_DoMatch(unsigned char* yuvArr, char* pRetSn);

void fuma_Bar2D_DoMatch(UIImage* pUIImage, char* pRetSn);



@interface FumarIOS2 : NSObject

@end
