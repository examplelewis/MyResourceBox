#import <TMAPIClient.h>

- (void)setTumblr {
    [TMAPIClient sharedInstance].OAuthConsumerKey = [MRBUserManager defaultManager].tumblr_OAuth_Consumer_Key;
    [TMAPIClient sharedInstance].OAuthConsumerSecret = [MRBUserManager defaultManager].tumblr_OAuth_Consumer_Secret;
    [TMAPIClient sharedInstance].OAuthToken = [MRBUserManager defaultManager].tumblr_OAuth_Token;
    [TMAPIClient sharedInstance].OAuthTokenSecret = [MRBUserManager defaultManager].tumblr_OAuth_Token_Secret;
}
