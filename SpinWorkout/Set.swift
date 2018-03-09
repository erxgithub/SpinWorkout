//
//  Set.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import Foundation

class Set {
    
    //MARK: Properties
    
    var number: Int
    var gear: Int
    var cadence: Int
    var seconds: Double
    
    //MARK: Initialization
    
    init?(number: Int, gear: Int, cadence: Int, seconds: Double) {
        
        self.number = number
        self.gear = gear
        self.cadence = cadence
        self.seconds = seconds
        
    }
    
}
