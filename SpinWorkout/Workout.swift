//
//  Workout.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import Foundation

class Workout {
    
    //MARK: Properties
    
    var title: String
    var sets: [Set]?
    
    //MARK: Initialization
    
    init?(title: String?, sets: [Set]?) {
        self.title = title ?? ""
        self.sets = sets ?? []
    }
    
}
