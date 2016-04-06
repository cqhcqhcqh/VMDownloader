//
//  StateMachine.swift
//  StateMachine-Swift
//
//  Created by Cnepay on 15/11/2.
//  Copyright © 2015年 Cnepay. All rights reserved.
//

import UIKit

public class StateMachine: NSObject {
   public var runloopThread:NSThread?
//    static var unconnectState:State =  {
//        return UnconnectState()
//    }()
    
//    var destiedState:CPState?
//    var currentState:CPState!;
//    
//    
    var mSmHandler:SmHandler!;
    override init() {
        mSmHandler = SmHandler()
        
    }
    
    func start() {
        mSmHandler.completeConstruction()
    }
    
    func transitionTo(destState:State?) {
        self.mSmHandler.transitionTo(destState!);//.destState = destState
    }
//
//    
//    lazy var deferredArray:Array<CPMessage> = [CPMessage]()
//    
//    func transitionState(){
//        
//        while destiedState != nil && self.currentState !== destiedState {
//            self.currentState.exit();
//            self.currentState = self.destiedState!
//            self.currentState.enter()
//        }
//        self.destiedState = nil;
//    }
    
    func hasDeferredMessage(type:MESSAGETYPE) ->Bool {
        
        for message in self.mSmHandler.deferredArray {
            if message.type == type {
                return true
            }
        }
        return false;
    }
    
    func removeDeferredMessage(type:MESSAGETYPE) {
        var tempDeferredArray :Array<CPMessage> = [CPMessage]();
        
        for message in self.mSmHandler.deferredArray {
            if message.type != type {
                tempDeferredArray.append(message);
            }
        }
        self.mSmHandler.deferredArray.removeAll();
        self.mSmHandler.deferredArray = tempDeferredArray;
    }
    
    func sendMessage(message:CPMessage)
    {
        self.mSmHandler.addOperationAtEndOfQueue(message)
    }
    
    func sendMessageFront(message:CPMessage) {
        
        self.mSmHandler.addOperationAtFrontOfQueue(message);
    }
    
    func deferredMessage(message:CPMessage){
        
        self.mSmHandler.deferredArray.append(message)
    }
    
    func addState(state:State,parentState:State?) {
        
        self.mSmHandler.addState(state, parentState: parentState);
    }
    
}


