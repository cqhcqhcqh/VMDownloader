//
//  StateInfo.swift
//  StateMachine-Swift
//
//  Created by Cnepay on 15/11/2.
//  Copyright © 2015年 Cnepay. All rights reserved.
//

import UIKit


class StateInfo: NSObject {
    var state:State;
    var parentStateInfo:StateInfo?
    var active:Bool = false;
    
    init(state:State) {
        self.state = state
        super.init()
        
    }
    
    
}
