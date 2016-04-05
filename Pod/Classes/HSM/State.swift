//
//  State.swift
//  StateMachine-Swift
//
//  Created by Cnepay on 15/11/2.
//  Copyright © 2015年 Cnepay. All rights reserved.
//

import UIKit

class State: NSObject {
    
    func processMessage(message:CPMessage) -> Bool{
        return false;
    }
    
    unowned var stateMachine:StateMachine;
    init(stateMachine:StateMachine) {
        self.stateMachine = stateMachine;
        super.init();
    }
    
    /*
    *
    //1、使用原始值初始化枚举变量
    let action = ACTION(rawValue: "ACTION_CHOOSEDEVICE");
    print(action?.rawValue);
    //2、action是一个可选类型类型,因为原始值构造器是一个可失败构造器init?
    */

    var name : String {
        return NSStringFromClass(self.dynamicType)
    }
    
    func sendMessage(type:MESSAGETYPE, obj:AnyObject?,subType:Int?){
        let message = CPMessage();
        message.type = type;
        message.subType = subType;
        message.obj = obj;
        self.stateMachine.sendMessage(message)
    }
    
    func sendMessage(type:MESSAGETYPE) {
        self.sendMessage(type, obj: nil, subType: nil);
    }
    
    func sendMessage(type:MESSAGETYPE,obj:AnyObject?){
        self.sendMessage(type, obj: obj, subType: nil);
    }
    
    
    func deferredMessage(message:CPMessage){
        self.stateMachine.deferredMessage(message);
    }
    
    func removeDeferredMessage(type:MESSAGETYPE) {
        self.stateMachine.removeDeferredMessage(type);
    }
    
    func exit() {
//        print("exit-----\(self.name)");
        
    }
    
    func enter() {
        print("enter-----\(self.name)");
        
//        for (_ ,value) in self.stateMachine.deferredArray.enumerate() {
//            self.stateMachine.sendMessageFront(value);
//        }
//        
//        self.stateMachine.deferredArray.removeAll();
    }
}
