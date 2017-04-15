//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <25519/Curve25519.h>

#import "OWSUnitTestEnvironment.h"
#import "SecurityUtils.h"
#import "TSPrivacyPreferences.h"
#import "TSStorageManager+IdentityKeyStore.h"
#import "TSStorageManager.h"
#import "TextSecureKitEnv.h"
#import "OWSDispatch.h"

@interface TSStorageIdentityKeyStoreTests : XCTestCase

@end

@implementation TSStorageIdentityKeyStoreTests

- (void)setUp {
    [super setUp];
    [[TSStorageManager sharedManager] purgeCollection:@"TSStorageManagerTrustedKeysCollection"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNewEmptyKey {
    NSData *newKey = [SecurityUtils generateRandomBytes:32];
    NSString *recipientId = @"test@gmail.com";
    
    XCTAssert([[TSStorageManager sharedManager] isTrustedIdentityKey:newKey recipientId:recipientId]);
}

- (void)testAlreadyRegisteredKey {
    NSData *newKey = [SecurityUtils generateRandomBytes:32];
    NSString *recipientId = @"test@gmail.com";
    
    XCTestExpectation *testComplete = [self expectationWithDescription:@"hasSafetyNumbers"];
    dispatch_async([OWSDispatch sessionStoreQueue], ^{
        [[TSStorageManager sharedManager] saveRemoteIdentity:newKey recipientId:recipientId];
        XCTAssert([[TSStorageManager sharedManager] isTrustedIdentityKey:newKey recipientId:recipientId]);
        [testComplete fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}


- (void)testChangedKeyWithBlockingIdentityChanges
{
    TSPrivacyPreferences *preferences = [TSPrivacyPreferences sharedInstance];
    preferences.shouldBlockOnIdentityChange = YES;
    [preferences save];

    NSData *newKey = [SecurityUtils generateRandomBytes:32];
    NSString *recipientId = @"test@gmail.com";

    XCTestExpectation *testComplete = [self expectationWithDescription:@"hasSafetyNumbers"];
    dispatch_async([OWSDispatch sessionStoreQueue], ^{
        [[TSStorageManager sharedManager] saveRemoteIdentity:newKey recipientId:recipientId];
        
        XCTAssert([[TSStorageManager sharedManager] isTrustedIdentityKey:newKey recipientId:recipientId]);
        
        NSData *otherKey = [SecurityUtils generateRandomBytes:32];
        
        XCTAssertFalse([[TSStorageManager sharedManager] isTrustedIdentityKey:otherKey recipientId:recipientId]);
        
        [testComplete fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}


- (void)testChangedKeyWithNonBlockingIdentityChanges
{
    TSPrivacyPreferences *preferences = [TSPrivacyPreferences sharedInstance];
    preferences.shouldBlockOnIdentityChange = NO;
    [preferences save];

    NSData *newKey = [SecurityUtils generateRandomBytes:32];
    NSString *recipientId = @"test@gmail.com";

    XCTestExpectation *testComplete = [self expectationWithDescription:@"hasSafetyNumbers"];
    dispatch_async([OWSDispatch sessionStoreQueue], ^{
        
        [[TSStorageManager sharedManager] saveRemoteIdentity:newKey recipientId:recipientId];
        
        XCTAssert([[TSStorageManager sharedManager] isTrustedIdentityKey:newKey recipientId:recipientId]);
        
        NSData *otherKey = [SecurityUtils generateRandomBytes:32];
        
        [TextSecureKitEnv setSharedEnv:[OWSUnitTestEnvironment new]];
        XCTAssertTrue([[TSStorageManager sharedManager] isTrustedIdentityKey:otherKey recipientId:recipientId]);
        
        [testComplete fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testIdentityKey {
    [[TSStorageManager sharedManager] generateNewIdentityKey];
    
    XCTAssert([[[TSStorageManager sharedManager] identityKeyPair].publicKey length] == 32);
}

@end
