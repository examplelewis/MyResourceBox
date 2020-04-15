//
//  MRBResourceSites.m
//  MyResourceBox
//
//  Created by 龚宇 on 20/03/20.
//  Copyright © 2020 gongyuTest. All rights reserved.
//

#import "MRBResourceSites.h"
#import "MRBSitesImageDownloadWindowController.h"

@implementation MRBResourceSites

+ (void)configMethod:(NSInteger)cellRow {
    switch (cellRow) {
        case 1: {
            MRBSitesImageDownloadWindowController *wc = [[MRBSitesImageDownloadWindowController alloc] initWithWindowNibName:@"MRBSitesImageDownloadWindowController"];
            NSModalResponse response = [[NSApplication sharedApplication] runModalForWindow:wc.window];
            wc.response = response;
            [wc.window close];
        }
            break;
        case 2: {
            
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