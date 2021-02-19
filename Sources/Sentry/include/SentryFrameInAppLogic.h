#import "SentryDefines.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SentryFrameInAppLogic : NSObject
SENTRY_NO_INIT

- (instancetype)initWithInAppIncludes:(NSArray<NSString *> *)inAppIncludes
                        inAppExcludes:(NSArray<NSString *> *)inAppExcludes;

/** Determines with the imageName of a frame of a stacktrace wether it is related to the execution
 * of the relevant code in this stack trace.
 */
- (BOOL)isInApp:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
