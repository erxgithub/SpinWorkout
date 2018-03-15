//
//  Functions.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-14.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit

func timeString(interval: TimeInterval, format: String) -> String {
    let ti = Int(interval)
    
    let seconds = ti % 60
    let minutes = (ti / 60) % 60
    let hours = (ti / 3600)
    
    if format.lowercased() == "hm" {
        return String(format: "%dh %0.2dm", hours, minutes)
    } else if format.lowercased() == "hms" {
        return String(format: "%d.%0.2d.%0.2d", hours, minutes, seconds)
    } else {
        return String(format: "%dh %0.2dm %0.2ds", hours, minutes, seconds)
    }
}

func timeComponent(value: Double, component: String) -> Int {
    let tv = Int(value)
    
    let seconds = tv % 60
    let minutes = (tv / 60) % 60
    let hours = (tv / 3600)
    
    if component.lowercased() == "h" {
        return hours
    } else if component.lowercased() == "m" {
        return minutes
    } else {
        return seconds
    }
}

func timeValue(hours: Int, minutes: Int, seconds: Int) -> Double {
    let tv = Double(hours * 3600) + Double(minutes * 60) + Double(seconds)
    return tv
}
