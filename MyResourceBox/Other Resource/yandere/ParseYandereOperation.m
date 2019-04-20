//
//  ParseYandereOperation.m
//  MyToolBox
//
//  Created by 龚宇 on 16/05/04.
//  Copyright © 2016年 gongyuTest. All rights reserved.
//

#import "ParseYandereOperation.h"
#import "TFHpple.h"

@interface ParseYandereOperation ()

@property (strong) NSData *dataToParse;

@end

@implementation ParseYandereOperation

@synthesize dataToParse;
@synthesize imgURL;
@synthesize url;
@synthesize errorHandler;

- (instancetype)initWithData:(NSData *)data andURLstring:(NSString *)urlString {
    self = [super init];
    
    if (self) {
        dataToParse = data;
        url = urlString;
    }
    
    return self;
}

- (void)main {
    [self parsing];
}

- (void)parsing {
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:dataToParse];
    NSArray *herfArray = [xpathParser searchWithXPathQuery:@"//a"];
    BOOL found = NO;
    
    for (TFHppleElement *elemnt in herfArray) {
        NSString *string = [elemnt raw];
        NSRange pngRange = [string rangeOfString:@"Download PNG"];
        NSRange largerRange = [string rangeOfString:@"Download larger version"];
        
        if (pngRange.location != NSNotFound) {
            NSArray *component = [string componentsSeparatedByString:@"\""];
            for (NSString *string in component) {
                if ([string hasPrefix:@"https://files.yande.re/image"]) {
                    found = YES;
                    imgURL = string;
                    
                    break;
                }
            }
        } else if (largerRange.location != NSNotFound) {
            NSArray *component = [string componentsSeparatedByString:@"\\\""];
            for (NSString *string in component) {
                if ([string hasPrefix:@"https://files.yande.re/image"]) {
                    found = YES;
                    imgURL = string;
                    
                    break;
                }
            }
        }
    }

    if (!found && errorHandler) {
        NSError *error = [NSError errorWithDomain:@"MyToolBoxErrorDomainCannotParseYandereImage" code:-100001 userInfo:@{@"original":url, NSLocalizedDescriptionKey:@"在HTML页面中找不到Download PNG或者Download larger version标签"}];
        errorHandler(error);
    }
}

@end
