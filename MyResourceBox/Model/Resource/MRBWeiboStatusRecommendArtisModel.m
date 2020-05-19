//
//  MRBWeiboStatusRecommendArtisModel.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/05/08.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBWeiboStatusRecommendArtisModel.h"

@implementation MRBWeiboStatusRecommendArtisModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        NSMutableArray *artists = [NSMutableArray array];
        NSMutableString *desc = [NSMutableString string];
        
        NSArray *textComps = [self.text componentsSeparatedByString:@"\n"];
        
        // twitter
        NSArray *twitterComps = [textComps filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] 'twi'"]];
        for (NSInteger i = 0; i < twitterComps.count; i++) {
            NSString *text = twitterComps[i];
            
            text = [text stringByReplacingOccurrencesOfString:@"：" withString:@":" options:NSCaseInsensitiveSearch range:NSMakeRange(0, text.length)];
            text = [text stringByReplacingOccurrencesOfString:@"twitter:" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, text.length)];
            text = [text stringByReplacingOccurrencesOfString:@"twitter：" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, text.length)];
            text = [text stringByReplacingOccurrencesOfString:@"twi:" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, text.length)];
            text = [text stringByReplacingOccurrencesOfString:@"twi：" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, text.length)];
            text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if ([text hasPrefix:@"twi:"] || [text hasPrefix:@"twi："]) {
                text = [text substringFromIndex:4];
            }
            if ([text hasPrefix:@"Twi:"] || [text hasPrefix:@"Twi："]) {
                text = [text substringFromIndex:4];
            }
            
            if ([text hasPrefix:@"Twitter:"] || [text hasPrefix:@"Twitter："]) {
                text = [text substringFromIndex:8];
            }
            if ([text hasPrefix:@"Twitter:"] || [text hasPrefix:@"Twitter："]) {
                text = [text substringFromIndex:8];
            }
            
            [artists addObject:@{@"twitter": text}];
            [desc appendFormat:@"https://twitter.com/%@\n", text];
        }
        
        //
        
        
        if (desc.length >= 1) {
            [desc deleteCharactersInRange:NSMakeRange(desc.length - 1, 1)];
        }
        
        _recommendSites = [artists copy];
        _recommendDescription = [desc copy]; // 去除最后一个换行符
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"created_at: %@\nid_str: %@\nimg_urls_str: %@\nuser_screen_name: %@\nuser_id_str: %@\nrecommendSites: %@", self.created_at, self.id_str, self.img_urls_str, self.user_screen_name, self.user_id_str, _recommendSites];
}

+ (NSDictionary *)generateDictionaryWithText:(NSString *)text {    
    return @{@"user": @{@"screen_name": @"NULL", @"idstr": @"NULL"}, @"text": text};
}

@end
