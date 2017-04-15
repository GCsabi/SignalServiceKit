//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "OWSMessageSender.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TSNetworkManager;
@class TSOutgoingMessage;
@class TSAttachmentStream;

extern NSString *const kAttachmentUploadProgressNotification;
extern NSString *const kAttachmentUploadProgressKey;
extern NSString *const kAttachmentUploadAttachmentIDKey;

@interface OWSUploadingService : NSObject

// FIXME add sharedManager and assertSingleton

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNetworkManager:(id<TSNetworkManager>)networkManager NS_DESIGNATED_INITIALIZER;

- (void)uploadAttachmentStream:(TSAttachmentStream *)attachmentStream
                       message:(TSOutgoingMessage *)outgoingMessage
                       success:(void (^)())successHandler
                       failure:(RetryableFailureHandler)failureHandler;

@end

NS_ASSUME_NONNULL_END
