- (instancetype)initWithCookieFileType:(CookieFileType)filetype {
    self = [super init];
    if (self) {
        switch (filetype) {
            case CookieFileTypeLofter:
                file_name = @"LofterCookie.txt";
                cookie_domain = @"http://lofter.com/";
                break;
        }
    }
    
    return self;
}
