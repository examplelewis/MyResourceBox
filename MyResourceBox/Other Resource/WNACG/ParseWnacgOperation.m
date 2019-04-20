//
//  ParseWnacgOperation.m
//  MyToolBox
//
//  Created by 龚宇 on 16/04/29.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "ParseWnacgOperation.h"
#import "TFHpple.h"

@interface ParseWnacgOperation ()

@property (strong) NSData *dataToParse;

@end

@implementation ParseWnacgOperation

@synthesize dataToParse;
@synthesize imgURL;
@synthesize errorHandler;

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    
    if (self) {
        dataToParse = data;
    }
    
    return self;
}

- (void)main {
    [self parsing];
}

- (void)parsing {
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:dataToParse];
    NSArray *array = [xpathParser searchWithXPathQuery:@"//img"];
    
    for (TFHppleElement *elemnt in array) {
        NSDictionary *dic = [elemnt attributes];
        NSString *string = [dic objectForKey:@"src"];
        
        if ([string hasPrefix:@"http://img.wnacg.us/"]) {
//            NSLog(@"%@", string);
            imgURL = string;
            
            break;
        }
    }
}


@end
