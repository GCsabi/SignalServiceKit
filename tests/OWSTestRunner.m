//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "OWSTestRunner.h"
#import "OWSUnitTestEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@implementation OWSTestRunner

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return self;
    }

    NSLog(@"%@ Setting TextSecureKitEnv to OWSUnitTestEnvironment", self.tag);
    [TextSecureKitEnv setSharedEnv:[OWSUnitTestEnvironment new]];

    return self;
}

#pragma mark - Logging

+ (NSString *)tag
{
    return [NSString stringWithFormat:@"[%@]", self.class];
}

- (NSString *)tag
{
    return self.class.tag;
}

@end

NS_ASSUME_NONNULL_END
