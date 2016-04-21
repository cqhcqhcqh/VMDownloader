//
//  SmHandler.h
//  Pods
//
//  Created by chengqihan on 16/4/7.
//
//

#import "CPMessagesQueue.h"
@class StateMachine;

@class State;
@interface StateInfo : NSObject
@property (readwrite, nonatomic, strong) State *state;
@property (readwrite, nonatomic, strong) StateInfo *parentStateInfo;
@property (readwrite, nonatomic, assign) BOOL active;
- (instancetype)initWithState:(State *)state;
+ (instancetype)stateInfoWithState:(State *)state;
@end

@interface SmHandler : CPMessagesQueue

@property (readwrite, nonatomic, strong) NSMutableArray *deferredArray;
@property (readwrite, nonatomic, strong) State *initialState;
@property (readonly, nonatomic, strong) NSMutableDictionary *mapStateInfo;
@property (nonatomic, weak) StateMachine* handlerDelegate;

- (void)completeConstruction;
- (void)transitionToState:(State *)state;
- (StateInfo *)addState:(State *)state parentState:(State *)parentState;
- (void)quitNow;

- (BOOL)isQuit:(CPMessage *)msg;
@end
