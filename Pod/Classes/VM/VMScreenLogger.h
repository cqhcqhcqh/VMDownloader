//
//  VMScreenLogger.h
//  Pods
//
//  Created by chengqihan on 16/4/5.
//
//


@import CocoaLumberjack;
static const int ddLogLevel = DDLogLevelVerbose;

#define VMScreenLogger(...)   DDLogVerbose(__VA_ARGS__)
@interface VMScreenLogger : DDAbstractLogger

@end
