//
//  VMDownloadTask.swift
//  Pods
//
//  Created by chengqihan on 16/4/4.
//
//

import UIKit

class VMDownloadTask: StateMachine {
    var mInit:DownloadState?
    
    var mStarted:DownloadState?
    var mDownloading:DownloadState?
    var mWaiting:DownloadState?
    var mRetry:DownloadState?
    var mOngoing:DownloadState?
    
    var mVerifying:DownloadState?
    
    var mStopped:DownloadState?
    var mPaused:DownloadState?
    var mIOError:DownloadState?

    var mDone:DownloadState?
    var mSuccess:DownloadState?
    var mFailure:DownloadState?

    override init() {
        super.init()
        
        mInit = Init(stateMachine: self)
        mStarted = Started(stateMachine: self)
        mDownloading = Downloading(stateMachine: self)
        mWaiting = Waiting(stateMachine: self)
        mOngoing = Ongoing(stateMachine: self)
        mVerifying = Verifying(stateMachine: self)
        mStopped = Stopped(stateMachine: self)
        mPaused = Paused(stateMachine: self)
        mIOError = IOError(stateMachine: self)
        mDone = Done(stateMachine: self)
        mSuccess = Success(stateMachine: self)
        mFailure = Failure(stateMachine: self)
        
        self.addState(mInit!, parentState: nil)
        
            self.addState(mStarted!, parentState: mInit!)
                self.addState(mDownloading!, parentState: mStarted!)
                    self.addState(mRetry!, parentState: mDownloading!)
                    self.addState(mOngoing!, parentState: mDownloading!)
                self.addState(mWaiting!, parentState: mStarted!)
            self.addState(mVerifying!, parentState: mInit!)
            self.addState(mStopped!, parentState: mInit!)
        
                self.addState(mPaused!, parentState: mStopped!)
                self.addState(mIOError!, parentState: mStopped!)
            self.addState(mDone!, parentState: mInit!)
                self.addState(mSuccess!, parentState: mDone!)
                self.addState(mFailure!, parentState: mDone!)
        
        mSmHandler.setInitialState(mStarted!)
        super.start()
    }
    
    class Init: DownloadState {
        override func enter() {
            
        }
        override func exit() {
            
        }
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
    
    class Started: DownloadState {
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
    
    class Downloading: DownloadState {
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
    
    class Waiting: DownloadState {
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
    class Retry: DownloadState {
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
    class Ongoing: DownloadState {
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
    
    class Verifying: DownloadState {
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
    
    class Stopped: DownloadState {
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
    
    class Paused: DownloadState {
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
    class IOError: DownloadState {
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
    
    class Done: DownloadState {
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
    
    class Success: DownloadState {
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
    class Failure: DownloadState {
        override func processMessage(message: CPMessage) -> Bool {
            return false
        }
    }
}
