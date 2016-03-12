//
//  Pomodoro.swift
//  Pomodoro Flow
//
//  Created by Dan K. on 2016-03-13.
//  Copyright © 2016 Dan K. All rights reserved.
//

import Foundation

// Pomodoro is a singleton object that handles pomodoros and breaks logic
class Pomodoro {
    
    static let sharedInstance = Pomodoro()

    let userDefaults = NSUserDefaults.standardUserDefaults()
    let settings = SettingsManager.sharedManager
    
    var state: State = .Default
    
    private init() {}
    
    var pomodorosDone: Int {
        get {
            return userDefaults.integerForKey(currentDateKey)
        }
        set {
            userDefaults.setInteger(newValue, forKey: currentDateKey)
        }
    }
    
    func completePomodoro() {
        pomodorosDone += 1
        state = (pomodorosDone % 4 == 0 ? .LongBreak : .Break)
    }
    
    func completeBreak() {
        state = .Default
    }
    
    private var currentDateKey: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.stringFromDate(NSDate())
    }
    
}