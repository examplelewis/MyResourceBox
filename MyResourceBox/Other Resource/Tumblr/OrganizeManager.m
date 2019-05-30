- (void)startOrganizing {
    if ([plistName isEqualToString:@"JDlingyuRenameInfo"]) {
        folderName = @"绝对领域";
    } else if ([plistName isEqualToString:@"LofterRenameInfo"]) {
        folderName = @"Lofter";
    } else if ([plistName isEqualToString:@"weiboStatuses"]) {
        folderName = @"微博";
    } else if ([plistName isEqualToString:@"tumblrStatuses"]) {
        folderName = @"Tumblr";
    }
}
