//
//  SmHandler.m
//  Pods
//
//  Created by chengqihan on 16/4/7.
//
//

#import "SmHandler.h"
#import "CPLoggerManager.h"
#import "State.h"
#import "CPMessageOperation.h"
#import "StateMachine.h"

@implementation StateInfo
- (instancetype)initWithState:(State *)state {
    if (self == [super init]) {
        _state = state;
    }
    return self;
}
+ (instancetype)stateInfoWithState:(State *)state {
    return [[self alloc] initWithState:state];
}

@end


@interface SmHandler ()
@property (readwrite, nonatomic, strong) NSMutableDictionary *mapStateInfo;
@property (readwrite, nonatomic, strong) NSMutableArray *stateStack;
@property (readwrite, nonatomic, strong) NSMutableArray *tempStateStack;
@property (readwrite, nonatomic, assign) BOOL isConstructionCompleted;
@property (readwrite, nonatomic, assign) NSInteger stateStackTopIndex;
@property (readwrite, nonatomic, assign) NSInteger tempStateStackCount;
@property (readwrite, nonatomic, strong) State *destState;
@end

@implementation SmHandler
- (NSMutableArray *)deferredArray
{
    if (!_deferredArray) {
        _deferredArray = [NSMutableArray array];
    }
    return _deferredArray;
}

- (NSMutableDictionary *)mapStateInfo
{
    if (!_mapStateInfo) {
        _mapStateInfo = [NSMutableDictionary dictionary];
    }
    return _mapStateInfo;
}


/**
 *
 *  完成状态机 状态栈和临时状态栈的数组构建
 *  状态栈     [0....n] = [Init...CurrentState]
 *  临时状态栈  [0....n] = [CurrentState...Init]
 *  根据初始状态设定临时状态栈和实际状态栈
 *
 */
- (void)completeConstruction
{
    NSInteger maxDepth = 0;
    
    for (__strong StateInfo* stateInfo in self.mapStateInfo.allValues) {
        NSInteger depth = 1;
        while (stateInfo.parentStateInfo != nil) {
            stateInfo = stateInfo.parentStateInfo;
            depth += 1;
        }
        if (depth > maxDepth) {
            maxDepth  = depth;
        }
    }
    
    self.stateStack = [NSMutableArray arrayWithCapacity:maxDepth];
    self.tempStateStack = [NSMutableArray arrayWithCapacity:maxDepth];
    
    [self setupInitialStateStack];
    
    CPMessage *msg = [CPMessage messageWithType:MessageTypeEventInit];
    [self addOperationAtFrontOfQueue:msg];
}


/**
 *
 *  根据初始状态设定临时状态栈
 *  将临时状态栈的状态 倒序 的方式,存放在状态栈中
 */
- (void)setupInitialStateStack {
    
    //1、根据初始状态获取 状态对应的StateInfo
    StateInfo *curStateInfo = self.mapStateInfo[NSStringFromClass(self.initialState.class)];
    __block NSString *tempStateStackLog = @"临时状态栈构建完成:\n[";
    
    //2、构建临时状态栈
    while (curStateInfo != nil) {
        tempStateStackLog = [tempStateStackLog stringByAppendingFormat:@"index:%d state:%@,\n",_tempStateStackCount,NSStringFromClass(curStateInfo.state.class)];
        _tempStateStack[_tempStateStackCount++] = curStateInfo;
        curStateInfo = curStateInfo.parentStateInfo;
    }
    CPStateMechineLog(@"%@]",tempStateStackLog);
    
    //3、通过将栈顶的Index赋值为-1的方式,状态栈滞空。
    _stateStackTopIndex = -1;
    
    //4、将临时状态栈的状态 reverse之后,存放至状态栈中
    [self moveTempStateStackToStateStack];
    
}

#pragma mark - CPMessageOperationDelegate 消息队列的消息出口
- (void)sendMessageOperationDidStart:(CPMessageOperation *)operation message:(CPMessage *)message
{
    State *msgProcessedState = nil;
    if (self.isConstructionCompleted) {
        msgProcessedState = [self processMsg:message];
    }else if (!self.isConstructionCompleted && message.type == MessageTypeEventInit) {
        self.isConstructionCompleted = YES;
        //以栈底作为起始位置,依次将状态栈中的所有状态都激活同时调用Enter方法
        [self invokeEnterMethods:0];
    } else {
        //        VMStateMachineLogger(@"未初始化");
    }
    [self performTransitions:msgProcessedState message:message];
    CPStateMechineLog(@">>>>>>>>>>>>>>>>>>任务%@------------结束------------\n\n",MessageMapping[message.type]);
    
//    NSAssert(self.handlerDelegate != nil, @"StateMachine is nil");
    if ([self.handlerDelegate respondsToSelector:@selector(smHandlerProcessFinalMessage:)]) {
        [self.handlerDelegate smHandlerProcessFinalMessage:message];
    }
    
}

- (void)performTransitions:(State *)msgProcessedState message:(CPMessage *)msg {
    State *tempDestState = self.destState;
    
    if (tempDestState != nil) {
        while (true) {
            //A-C-E-H ==> A-C-G-I
            
            //1、根据目的状态,构建临时状态栈[I,G,nil,nil],根据目的状态向上追溯父状态,返回第一个没有被激活的父状态
            StateInfo *commonStateInfo = [self setupTempStateStackWithStatesToEnter:tempDestState];
            
            //2、状态栈依次退出H-E变成A-C,调整状态栈栈顶的Index,此例中:指向C的位置,也就是1。状态栈的那个数组还是A-C-E-H,只不过H/E的active已经被至为NO,并且调用了对应状态的Enter方法
            [self invokeExitMethods:commonStateInfo];
            
            //3、将临时状态栈中的状态倒序存放到状态栈中-->状态栈中的状态就变成了 A-C-G-I(状态栈的那个数组实际上此时才发生了变化),return出需要第一个需要Enter状态的Index
            NSInteger stateStackEnteringIndex = [self moveTempStateStackToStateStack];
            
            //4、将状态栈中的所有状态对应的状态节点[StateInfo:State的一种包装]的active设定为true,然后还需要调用状态的Enter方法
            [self invokeEnterMethods:stateStackEnteringIndex];
            
            //5、保证deferredArray中的message在切换到下一个状态时,优先解决~~~
            [self moveDeferredMessageAtFrontOfQueue];
            
            if (tempDestState != self.destState) {
                tempDestState = self.destState;
            } else {
                CPStateMechineLog(@"状态切换成 %@",[self.destState getName]);
                break;
            }
        }
    }
    self.destState = nil;
}

/**
 *  将临时状态栈中的状态倒序存放至实际状态栈中
 *
 *  存放之后将状态栈的TopIndex调整至栈顶
 *
 *  @return 将第一个需要存放的状态对应的Index return出去
 */
- (NSInteger)moveTempStateStackToStateStack {
    
    NSInteger startIndex =  _stateStackTopIndex + 1;
    
    //1、确定临时状态栈,取出的状态的起始Index
    NSInteger i = _tempStateStackCount - 1;
    
    //2、确定状态栈,存放的状态的起始Index
    NSInteger j = startIndex;
    while (i >= 0) {
        //3、将临时状态栈中的状态 倒序 存放至 状态栈中
        _stateStack[j] = _tempStateStack[i];
        j += 1;
        i -= 1;
    }
    
#ifdef DEBUG
    __block NSString* acturalStateStackDesc = @"实际状态栈结构切成:\n[";
    [_stateStack enumerateObjectsUsingBlock:^(StateInfo*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        acturalStateStackDesc = [acturalStateStackDesc stringByAppendingFormat:@"index:%zd state:%@,\n",idx,NSStringFromClass([obj.state class])];
    }];
    CPStateMechineLog(@"%@]",acturalStateStackDesc);
#endif
    
    //4、调整状态栈的栈顶的Index,指向状态栈的栈顶位置
    _stateStackTopIndex = j - 1;
    
    //5、将状态栈的栈顶 return出去
    return startIndex;
    
}

/**
 *  根据目的状态去构建临时状态栈
 *
 *  @param destState 目的状态
 *
 *  @return 返回 目的状态 向上追溯状态的第一个没有被激活的父状态
 *  举例:
 *  目标状态是I
 *  当前状态栈 =>  目标状态栈
 *  [A,C,E,H] => [A,C,G,I]
 
 *  临时状态栈构建成[I,G,nil,nil]
 *  return C(目的状态 向上追溯状态的第一个没有被激活的父状态)
 
 */
- (StateInfo *)setupTempStateStackWithStatesToEnter:(State *)destState {
    _tempStateStackCount = 0;
    
    //1、获取目的状态的StateInfo
    StateInfo *destStateInfo = self.mapStateInfo[NSStringFromClass(destState.class)];
    NSString *log = @"构建需要Enter的State的临时状态栈:\n[";
    do {
        //2、首先将目的状态存放至临时状态栈中
        log = [log stringByAppendingFormat:@"index:%zd state:%@,\n active:%@",_tempStateStackCount,[destStateInfo.state getName],destStateInfo.active?@"激活过了":@"未激活"];
        self.tempStateStack[_tempStateStackCount++] = destStateInfo;
        destStateInfo = destStateInfo.parentStateInfo;
        //3、如果目的状态有父状态,并且父状态没有active的话,继续做第二步的事情
    } while (destStateInfo != nil && !(destStateInfo.active));
    CPStateMechineLog(@"%@ destStateInfo:%@ state:%@ active:%@]\n",log,destStateInfo,[destStateInfo.state getName],[destStateInfo active]?@"激活过了":@"未激活");
    return destStateInfo;
    
}
/**
 *  从消息对类中移出之前Deferred的消息
 */
- (void)moveDeferredMessageAtFrontOfQueue {
    for (NSInteger i = 0; i < self.deferredArray.count; i++) {
        CPMessage *msg = self.deferredArray[i];
        
        StateInfo *topStackStateInfo = self.stateStack[_stateStackTopIndex];
        CPStateMechineLog(@"currentState: %@ ------即将优先处理的消息---%@",[[topStackStateInfo state] getName],MessageMapping[msg.type]);
        [self addOperationAtFrontOfQueue:msg];
    }
    [self.deferredArray removeAllObjects];
}

/**
 * 沿着状态栈 不断向根节点追溯以判断是否能解决message
 */
- (State *)processMsg:(CPMessage *)msg {
    StateInfo *curStateInfo = self.stateStack[_stateStackTopIndex];
    CPStateMechineLog(@">>>>curState:%@------EVENT:---%@",[[curStateInfo state] getName],MessageMapping[msg.type]);
    if ([self isQuit:msg]) {
        NSAssert(self.handlerDelegate != nil, @"StateMachine is nil");
        [self transitionToState:self.handlerDelegate.quittingState];
    }else {
        while (![curStateInfo.state processMessage:msg]) {
            if (curStateInfo.parentStateInfo != nil) {
                curStateInfo = curStateInfo.parentStateInfo;
                CPStateMechineLog(@">>>>>>curState's ParentState:%@------EVENT:---%@",[[curStateInfo state] getName],MessageMapping[msg.type]);
            }else {
                [self unhandledMessage:msg];
                break;
            }
        }
    }
    return curStateInfo.state;
}

/**
 *
 *  栈底层[根节点] 到 从栈顶[当前的节点状态] 依次调用enter(),然后将State对应的StateInfo[状态节点]的active改成true
 *
 *  @param startIndex 起始位置
 */
- (void)invokeEnterMethods:(NSInteger)startIndex {
    for (NSInteger index = startIndex; index <= self.stateStackTopIndex; index++) {
        StateInfo *stateInfo = self.stateStack[index];
        [stateInfo.state enter];
        CPStateMechineLog(@"%@ ENTER....",NSStringFromClass([stateInfo.state class]));
        [stateInfo setActive:YES];
    }
}

/**
 *  根据共同的父节点,依次退出当前状态栈,需要退出的状态
 *  举例:[A,C,E,H] => [A,C,G,I]
 *  共同的父节点就是C,需要退出当前状态栈 E,H状态,同时将栈顶的Index指向C的位置,也就是1
 *  @param stateInfo 共同父节点 (当前状态栈和目标状态栈的共同节点)
 */
- (void)invokeExitMethods:(StateInfo *)stateInfo {
    
    while (_stateStackTopIndex >= 0 && self.stateStack[_stateStackTopIndex] != stateInfo) {
        StateInfo *curStateInfo =  self.stateStack[_stateStackTopIndex];
        State *curState = [curStateInfo state];
        [curState exit];
        CPStateMechineLog(@"%@ EXIT....",NSStringFromClass([curState class]));
        [curStateInfo setActive:NO];
        _stateStackTopIndex -= 1;
    }
}

- (void)unhandledMessage:(CPMessage *)message {
    
}


/**
 *  构造状态树
 *
 *  @param state       子状态
 *  @param parentState 父状态
 *
 *  @return 包装状态的StateInfo
 */

- (StateInfo *)addState:(State *)state parentState:(State *)parentState {
    StateInfo * parentStateInfo = nil;
    if (parentState != nil) {
        parentStateInfo = self.mapStateInfo[NSStringFromClass(parentState.class)];
        if (parentStateInfo == nil) {
            parentStateInfo = [self addState:parentState parentState:nil];
        }
    }
    
    StateInfo *stateInfo = self.mapStateInfo[NSStringFromClass(state.class)];
    if (stateInfo == nil) {
        stateInfo = [StateInfo stateInfoWithState:state];
        [self.mapStateInfo setObject:stateInfo forKey:NSStringFromClass(state.class)];
    }
    
    if (stateInfo.parentStateInfo != nil && stateInfo.parentStateInfo != parentStateInfo) {
        
    }
    
    stateInfo.parentStateInfo = parentStateInfo;
    stateInfo.active = NO;
    return stateInfo;
}

/**
 *  设定状态机的目的状态
 *
 *  @param state 目的状态
 */
- (void)transitionToState:(State *)state
{
    CPStateMechineLog(@"状态机的目的状态切换成 %@",[state getName]);
    self.destState = state;
}

/**
 *  退出状态机
 */
- (void)quitNow {
    CPMessage *msg = [CPMessage messageWithType:MessageTypeActionQuit obj:self];
    [self addOperationAtFrontOfQueue:msg];
}

- (BOOL)isQuit:(CPMessage *)msg{
    if(msg.type == MessageTypeActionQuit && msg.obj == self) {
        return YES;
    }
    return NO;
}
@end
