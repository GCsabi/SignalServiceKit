//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "TSIncomingMessage.h"
#import "TSInvalidIdentityKeySendingErrorMessage.h"
#import "TSOutgoingMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class TSStorageManager;
@class OWSSignalServiceProtosEnvelope;
@class OWSSignalServiceProtosDataMessage;
@class OWSDisappearingMessagesJob;
@class OWSMessageSender;
@protocol ContactsManagerProtocol;
@protocol ContactsUpdater;
@protocol OWSCallMessageHandler;
@protocol TSNetworkManager;

@interface TSMessagesManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)sharedManager;

// TODO can these be private?
@property (nonatomic, readonly) YapDatabaseConnection *dbConnection;
@property (nonatomic, readonly) id<TSNetworkManager> networkManager;
@property (nonatomic, readonly) id<ContactsUpdater> contactsUpdater;

- (void)handleReceivedEnvelope:(OWSSignalServiceProtosEnvelope *)envelope;

/**
 * Processes all kinds of incoming envelopes with a data message, along with any attachments.
 *
 * @returns
 *   If an incoming message is created, it will be returned. If it is, for example, a group update,
 *   no incoming message is created, so nil will be returned.
 */
- (TSIncomingMessage *)handleReceivedEnvelope:(OWSSignalServiceProtosEnvelope *)envelope
                              withDataMessage:(OWSSignalServiceProtosDataMessage *)dataMessage
                                attachmentIds:(NSArray<NSString *> *)attachmentIds;

/**
 * @returns
 *   Group or Contact thread for message, creating a new one if necessary.
 */
- (TSThread *)threadForEnvelope:(OWSSignalServiceProtosEnvelope *)envelope
                    dataMessage:(OWSSignalServiceProtosDataMessage *)dataMessage;

- (NSUInteger)unreadMessagesCount;
- (NSUInteger)unreadMessagesCountExcept:(TSThread *)thread;
- (NSUInteger)unreadMessagesInThread:(TSThread *)thread;

@end

NS_ASSUME_NONNULL_END
