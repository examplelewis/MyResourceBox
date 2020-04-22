//
//  MRBResourceSites.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBResourceSites.h"
#import "MRBSitesImageUrlFetchWindowController.h"
#import "MRBSitesImageDownloadManager.h"

@implementation MRBResourceSites

+ (void)configMethod:(NSInteger)cellRow {
    switch (cellRow) {
        case 1: {
            MRBSitesImageUrlFetchWindowController *wc = [[MRBSitesImageUrlFetchWindowController alloc] initWithWindowNibName:@"MRBSitesImageUrlFetchWindowController"];
            NSModalResponse response = [[NSApplication sharedApplication] runModalForWindow:wc.window];
            wc.response = response;
            [wc.window close];
        }
            break;
        case 2: {
            [[MRBSitesImageDownloadManager new] chooseDownloadedFiles];
        }
            break;
        case 3: {
            
        }
            break;
        default:
            break;
    }
}

@end
