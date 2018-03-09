//
//  Set.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import Foundation

class SpinSet {
    
    //MARK: Properties
    
    var sequence: Int
    var gear: Int
    var cadence: Int
    var seconds: Double
    
    //MARK: Initialization
    
    init?(sequence: Int, gear: Int, cadence: Int, seconds: Double) {
        
        self.sequence = sequence
        self.gear = gear
        self.cadence = cadence
        self.seconds = seconds
        
    }
    
}
