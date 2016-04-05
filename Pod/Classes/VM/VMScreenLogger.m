//
//  VMScreenLogger.m
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//

#import "VMScreenLogger.h"

@implementation VMScreenLogger
- (void)logMessage:(DDLogMessage *)logMessage {
    NSString *logMsg = logMessage.message;
    
    if (self->_logFormatter)
    logMsg = [self->_logFormatter formatLogMessage:logMessage];
    
    if (logMsg) {
        // Write logMsg to wherever...
        NSLog(@"%@",logMsg);
    }
}
@end
