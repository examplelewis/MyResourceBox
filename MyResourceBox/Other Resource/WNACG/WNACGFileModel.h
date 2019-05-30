//
//  WNACGFileModel.h
//  MyResourceBox
//
//  Created by 龚宇 on 17/01/24.
//  Copyright © 2017年 gongyuTest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel.h>

@interface WNACGFileModel : JSONModel

@property (nonatomic, copy) NSString *webPageUrl;
@property (nonatomic, copy) NSString *downloadName;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *downloadPageUrl;
@property (nonatomic, copy) NSString *fileUrl;
@property (nonatomic, assign) BOOL webSuccess;
@property (nonatomic, assign) BOOL downloadSuccess;

@end
