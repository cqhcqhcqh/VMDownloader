//
//  CPMessageOperation.swift
//  StateMachine-Swift
//
//  Created by Cnepay on 15/10/18.
//  Copyright © 2015年 Cnepay. All rights reserved.
//

import UIKit


class CPMessage {
    
    var type :MESSAGETYPE?// = MESSAGETYPE.ACTION_CHOOSEDEVICE
    var subType:Int?
    var code = 0
    
    var obj:AnyObject?
}

//func  == (left:CPMessage,right:CPMessage) -> Bool {
//    
//    return (left.type == right.type);
//}
//
//func !=(left:CPMessage,right:CPMessage) -> Bool {
//    
//    return !(left == right);
//}


protocol CPMessageOperationDelegate {
    func sendMessageOperationDidStart(operation:CPMessageOperation,message:CPMessage) ->()
}

class CPMessageOperation: NSOperation {
    var message:CPMessage;
    var runLoopThread:NSThread!;
    var delegate:CPMessageOperationDelegate?
    
    
    private var _executing: Bool = false
    override var executing: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValueForKey("isExecuting")
                _executing = newValue
                didChangeValueForKey("isExecuting")
            }
        }
    }
    
    private var _finished: Bool = false;
    override var finished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValueForKey("isFinished")
                _finished = newValue
                didChangeValueForKey("isFinished")
            }
        }
    }

    
    init(message:CPMessage) {
        self.message = message;
        super.init()
    }
    
//    static var sendDeviceCommandThread:NSThread = {
//        let thread =  NSThread(target: CPMessageOperation.self, selector: "sendDeviceCommandThreadEntryPoint:", object: nil);
//        thread.start();
//        return thread;
//    }();
    
    
//    static func sendDeviceCommandThreadEntryPoint(thread:NSThread) ->() {
//        let currentThread = NSThread.currentThread();
//        currentThread.name = "SendDeviceCommand"
//        let currentRunLoop = NSRunLoop.currentRunLoop();
//        currentRunLoop.addPort(NSMachPort(), forMode: NSDefaultRunLoopMode);
//        currentRunLoop.run();
//    }
    
    override func start() {
        
        if self.cancelled {
            self.finished = true
            return
            
        }else if self.ready {
            self.executing = true
            self.performSelector("operationDidStart", onThread: runLoopThread, withObject: nil, waitUntilDone:false)
        }
    }
    
    func operationDidStart() -> (){
        self.delegate?.sendMessageOperationDidStart(self, message: self.message);
        self.finished = true;
    }
}


