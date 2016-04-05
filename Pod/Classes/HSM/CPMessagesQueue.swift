//
//  CPMessagesQueue.swift
//  StateMachine-Swift
//
//  Created by Cnepay on 15/10/18.
//  Copyright © 2015年 Cnepay. All rights reserved.
//

import UIKit


class CPMessagesQueue: NSOperationQueue {
    
    var lastOperation:CPMessageOperation?
    
    override init() {
        super.init()
        self.maxConcurrentOperationCount = 1;
    }
    
    func addOperationAtEndOfQueue(message:CPMessage) {
        let messageOperation = CPMessageOperation(message: message);
        messageOperation.delegate = self;
        
        if self.lastOperation != nil {
            messageOperation.addDependency(lastOperation!);
        }
        self.lastOperation = messageOperation;
        
        super.addOperation(messageOperation);
    }
    
    func addOperationAtFrontOfQueue(message:CPMessage) {
        let messageOperation = CPMessageOperation(message: message);
        messageOperation.delegate = self;
        
        for singleOperation in self.operations as! [CPMessageOperation] {
            if singleOperation.executing {
                messageOperation.addDependency(singleOperation);
            }else {
                singleOperation.addDependency(messageOperation);
            }
        }
        super.addOperation(messageOperation);
    }
    
    func removeOperationWithMessage(message:CPMessage) {
        for singleOperation in self.operations as! [CPMessageOperation] {
            if message.type ==  singleOperation.message.type {
                singleOperation.cancel()
            }
        }
    }
    
    
    
    //一个类型已经实现了协议中的所有要求，却没有声明为遵循该协议时，可以通过扩展(空的扩展体)来补充协议声明
    func sendMessageOperationDidStart(operation: CPMessageOperation, message: CPMessage) {
        
    }
    
}

extension CPMessagesQueue:CPMessageOperationDelegate {}
