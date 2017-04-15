//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "TSContactThread.h"
#import "TSStorageManager+identityKeyStore.h"
#import "OWSDispatch.h"
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSContactThreadTest : XCTestCase

@property (nonatomic) TSContactThread *contactThread;

@end

@implementation TSContactThreadTest

- (void)setUp
{
    self.contactThread = [TSContactThread getOrCreateThreadWithContactId:@"fake-contact-id"];
    [self.contactThread.storageManager removeIdentityKeyForRecipient:self.contactThread.contactIdentifier];
}

- (void)testHasSafetyNumbersWithoutRemoteIdentity
{
    XCTAssertFalse(self.contactThread.hasSafetyNumbers);
}

- (void)testHasSafetyNumbersWithRemoteIdentity
{
    XCTestExpectation *hasSafetyNumbers = [self expectationWithDescription:@"hasSafetyNumbers"];    
    dispatch_async([OWSDispatch sessionStoreQueue], ^{
        [self.contactThread.storageManager saveRemoteIdentity:[NSData new]
                                                  recipientId:self.contactThread.contactIdentifier];
        if (self.contactThread.hasSafetyNumbers) {
            [hasSafetyNumbers fulfill];
        } else {
            XCTFail(@"thread didn't have safety numbers");
        }
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end

NS_ASSUME_NONNULL_END
