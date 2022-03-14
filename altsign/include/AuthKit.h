#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AKDevice : NSObject
@property (class, readonly) AKDevice *currentDevice;
@property (strong, readonly) NSString *serialNumber;
@property (strong, readonly) NSString *uniqueDeviceIdentifier;
@property (strong, readonly) NSString *serverFriendlyDescription;
@end

@interface AKAppleIDSession : NSObject
- (instancetype)initWithIdentifier:(NSString *)identifier;
- (NSDictionary<NSString *, NSString *> *)appleIDHeadersForRequest:(NSURLRequest *)request;
@end

NS_ASSUME_NONNULL_END
