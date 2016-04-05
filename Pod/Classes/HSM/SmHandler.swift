//
//  SmHandler.swift
//  StateMachine-Swift
//
//  Created by Cnepay on 15/11/2.
//  Copyright © 2015年 Cnepay. All rights reserved.
//

import UIKit

class SmHandler: CPMessagesQueue {
    
    func completeConstruction() {
        
        var maxDepth = 0
        print(mapStateInfo)
        
        for var si in mapStateInfo.values {
            var depth = 1
            while (si.parentStateInfo != nil) {
                si = si.parentStateInfo!
                depth += 1;
            }
            
            if depth > maxDepth {
                maxDepth = depth
            }
        }
        
        stateStack = [StateInfo](count: maxDepth, repeatedValue: StateInfo(state: self.mInitialState));
        tempStateStack = [StateInfo](count: maxDepth, repeatedValue: StateInfo(state: self.mInitialState))
        
        self.setupInitialStateStack()
        
        let initMsg = CPMessage();
        initMsg.type = .EVENT_INIT
        
        self.addOperationAtFrontOfQueue(initMsg)
    }
    
    
    var isConstructionCompleted:Bool = false
    
    
// MARK: =================================================消息队列处理中的每一个operation开始处理消息
    override func sendMessageOperationDidStart(operation: CPMessageOperation, message: CPMessage) {
        
        var msgProcessedState:State?;
        
        if isConstructionCompleted {
            
            msgProcessedState = self.processMsg(message)
            
        }else if !isConstructionCompleted && message.type == .EVENT_INIT {
            isConstructionCompleted = true
            invokeEnterMethods(0)
        } else {
            //未初始化~~~~
        }
        
        performTransitions(msgProcessedState, message: message)
        
        print(">>>>>>>>>>>>>>>>>>任务\(message.type!.rawValue)------------结束------------\n\n")
    }
    
    
    /**
     * Invoke the enter method starting at the entering index to top of state stack
     * 让stateStack中的节点从stateIndex位置到栈顶的所有State调用Enter方法,以表示入栈
     */
    
// MARK: =================================================从栈顶[当前的节点状态] 到栈底层[根节点] 依次调用enter(),然后将State对应的StateInfo[状态节点]的active改成true
    func invokeEnterMethods(stateIndex:Int) {
        
        for index in stateIndex...stateStackTopIndex {
            stateStack[index].state.enter()
            stateStack[index].active = true
        }
    }
    
// MARK: =================================沿着状态栈 不断向根节点追溯以判断是否能解决message
    func processMsg(message:CPMessage) -> State {
        var curStateInfo = stateStack[stateStackTopIndex]
        
        print(">>>>curState:\(curStateInfo.state.name)------EVENT:---\(message.type!.rawValue)")
        while(!curStateInfo.state.processMessage(message)){
            
            if curStateInfo.parentStateInfo != nil {
                
                curStateInfo = curStateInfo.parentStateInfo!
                print(">>>>>>curState's ParentState:\(curStateInfo.state.name)------EVENT:---\(message.type!.rawValue)")
                
            }else {
                //
                self.unhandledMessage(message);
                break;
            }
        }
        
        return curStateInfo.state
    }
    

    // MARK: =================================切换状态,流程请查看HSM切换详情.jpg
//    func performTransitions2(msgProcessedState:State?,message:CPMessage) {
//        
//        let currentState = self.stateStack[stateStackTopIndex].state
//        
//        let tempDestState = self.destState;
//        
//        while (tempDestState != nil && currentState !== tempDestState) {
//            
//            //A-C-E-H ==> A-C-G-I
//            
//            //1、临时状态栈中 I-G-*-*
//            let commonStateInfo = self.setupTempStateStackWithStatesToEnter(tempDestState!)
//            
//            //2、状态战中 A-C,并且stateStackTopIndex = 1
//            invokeExitMethods(commonStateInfo);
//            
//            //3、将临时状态栈中的状态倒序存放到状态栈中 -->状态栈中的状态就变成了 A-C-G-I
//            let stateStackEnteringIndex = self.moveTempStateStackToStateStack()
//            
//            //4、将状态栈中的所有状态对应的状态节点[StateInfo:State的一种包装]的active设定为true,然后还需要调用状态的Enter方法
//            invokeEnterMethods(stateStackEnteringIndex)
//            
//            //5、保证deferredArray中的message在切换到下一个状态时,优先解决~~~
//            self.moveDeferredMessageAtFrontOfQueue()
//            
//            print("====>>>>>>>状态切换成:\(destState!.name)=======")
//            
//            destState = self.stateStack[stateStackTopIndex].state
//        }
//        
//        self.destState = nil;
//    }
    
// MARK: =================================切换状态,流程请查看HSM切换详情.jpg
    func performTransitions(msgProcessedState:State?,message:CPMessage) {
        
        let tempDestState = self.destState;
        
        if tempDestState != nil {
            
            while (true) {
                
                //A-C-E-H ==> A-C-G-I
                
                //1、临时状态栈中 I-G-*-*
               let commonStateInfo = self.setupTempStateStackWithStatesToEnter(tempDestState!)
                
                //2、状态战中 A-C,并且stateStackTopIndex = 1
                invokeExitMethods(commonStateInfo);
                
                //3、将临时状态栈中的状态倒序存放到状态栈中 -->状态栈中的状态就变成了 A-C-G-I
                let stateStackEnteringIndex = self.moveTempStateStackToStateStack()
                
                //4、将状态栈中的所有状态对应的状态节点[StateInfo:State的一种包装]的active设定为true,然后还需要调用状态的Enter方法
                invokeEnterMethods(stateStackEnteringIndex)
                
                //5、保证deferredArray中的message在切换到下一个状态时,优先解决~~~
                self.moveDeferredMessageAtFrontOfQueue()
                
                
                if (tempDestState !== self.destState) {
                    destState = tempDestState
                } else {
                    print(">>>>>>>>>>状态切换成:\(destState!.name)<<<<<<<<<<       ")
                    break
                }
            }
        }
        
        self.destState = nil;
    }

// MARK: =================================状态切换之前处理DeferredArray里面的msg
    lazy var deferredArray/*:Array<CPMessage>*/ = [CPMessage]()
    func moveDeferredMessageAtFrontOfQueue() {
        
        for var i = 0;i<self.deferredArray.count;i++ {
            let curMsg = self.deferredArray[i]
            print("currentState:\(self.stateStack[stateStackTopIndex].state.name)------即将优先处理的消息---\(curMsg.type!.rawValue)");
            self.addOperationAtFrontOfQueue(curMsg)
        }

        self.deferredArray.removeAll();
    }
    
    /**
    * Determine the states to exit and enter and return the
    * common ancestor state of the enter/exit states. Then
    * invoke the exit methods then the enter methods.
    * 将已经Enter过的节点状态放入到tempStateStack中,并且return一个目标节点[destState]和起始节点的公共节点
    * 查看HSM切换详情.jpg
    */
    
    func setupTempStateStackWithStatesToEnter(destState:State) ->StateInfo {
        tempStateStackCount = 0
        
        //目标状态的节点~
        var curStateInfo = mapStateInfo[destState];
        
        repeat {
            
            //目标节点...根节点 ==> [0....Count]
            tempStateStack[tempStateStackCount++] = curStateInfo!;
            curStateInfo = curStateInfo?.parentStateInfo
            
         //若次节点有父节点并且这个父节点未激活,入temp状态栈
         //若没有父节点,或者父节点已激活
            
// MARK: =================================================这里有崩溃的风险
        }while(curStateInfo != nil && !(curStateInfo!.active))
        
        ///然后将最后一个添加进中转状态栈中的状态返回，这就是切换的起始节点和终止节点的公共最近父状态节点
        return curStateInfo!;
    }
    
    /**
     * Call the exit method for each state from the top of stack
     * up to the common ancestor state.
     
     从状态栈的栈顶开始，依次执行exit，这样就是从起始节点向公共父状态进发，不断调用exit，同时不断把节点的active置为false，表示该节点已经被exit了
     */
    func invokeExitMethods(commonStateInfo:StateInfo) {
        while(stateStackTopIndex >= 0 && stateStack[stateStackTopIndex] !== commonStateInfo) {
            let curState = stateStack[stateStackTopIndex].state
            curState.exit()
            stateStack[stateStackTopIndex].active = false
            stateStackTopIndex -= 1
        }
    }

// MARK: ================================= 初始化状态栈和临时状态栈
    func unhandledMessage(message:CPMessage) {
        
    }
    var stateStack = [StateInfo]()
    var tempStateStack = [StateInfo]()
    var stateStackTopIndex = 0;
    var tempStateStackCount = 0
    
    
    func setupInitialStateStack() {
        var curStateInfo = mapStateInfo[mInitialState];
        
        while(curStateInfo != nil) {
            
            //tempStateStack状态栈中存放着 子节点~根节点[0....Count]
            //顺序是相反的....
            tempStateStack[tempStateStackCount++] = curStateInfo!;
            curStateInfo = curStateInfo?.parentStateInfo
        }
        
        stateStackTopIndex = -1
        
        //stateStack状态栈则存放着     跟节点~子节点[0....Count]
        self.moveTempStateStackToStateStack()
    }
    
    
    /**
    * Move the contents of the temporary stack to the state stack
    * reversing the order of the items on the temporary stack as
    * they are moved.
    *
    * @return index into mStateStack where entering needs to start
    */
    
// MARK: =================================================将临时状态栈中的所有状态倒序放入到 状态栈中
    func moveTempStateStackToStateStack() -> Int{
        let startingIndex = stateStackTopIndex + 1
        
        var i = tempStateStackCount - 1
        var j = startingIndex
        
        while (i >= 0) {
            stateStack[j] = tempStateStack[i]
            j += 1
            i -= 1
        }
        stateStackTopIndex = j - 1
        
        return stateStackTopIndex
    }
    
// MARK: =================================================构建状态树
    var mapStateInfo = [State:StateInfo]()
    
    func addState(state:State,parentState:State?) ->StateInfo!{
        var parentStateInfo:StateInfo?;
        if (parentState != nil) {
            parentStateInfo = mapStateInfo[parentState!];
            if parentStateInfo == nil {
                //map中获取不到stateInfo,就递归调用该方法进行创建~
                parentStateInfo = self.addState(parentState!, parentState: nil)
            }
        }
        
        var stateInfo:StateInfo? = mapStateInfo[state];
        if stateInfo == nil {
            stateInfo = StateInfo(state: state)
            mapStateInfo.updateValue(stateInfo!, forKey: state);
        }
        
        // Validate that we aren't adding the same state in two different hierarchies.
        //这里表示一个状态之间被添加进来的时候为其指定过一个
        //不是null的parent节点，但是现在又要给它指定一个新的parent，
        //这是不被允许的，因为这会导致一个节点位于状态树的不同层次上，
        //这会导致状态切换的紊乱
        if stateInfo?.parentStateInfo != nil && stateInfo?.parentStateInfo != parentStateInfo {
            //            NSException.raise("state already added", format: "%@", arguments: <#T##CVaListPointer#>)
        }
        
        stateInfo?.parentStateInfo = parentStateInfo;
        stateInfo?.active = false
        
        return stateInfo!;
    }
    
    
    var mInitialState:State!;
    func setInitialState(state:State) {
        self.mInitialState = state;
    }
    
    private var destState:State?
    func transitionTo(destState:State){
        self.destState = destState
    }
}
