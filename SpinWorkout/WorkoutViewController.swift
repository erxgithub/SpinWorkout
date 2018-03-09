//
//  WorkoutViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit

class WorkoutViewController: UIViewController {
    
    @IBOutlet weak var workoutTimerLabel: UILabel!
    @IBOutlet weak var startButtonLabel: UIButton!
    @IBOutlet weak var setTimerLabel: UILabel!
    @IBOutlet weak var gearLabel: UILabel!
    @IBOutlet weak var cadenceLabel: UILabel!
    
    var timer = Timer()
    var timerCountDown: Bool = true
    var timerPause: Bool = false
    var timeInterval: TimeInterval = 0.1
    
    var maxWorkoutTime: TimeInterval = 0.0
    var maxSetTime: TimeInterval = 0.0
    var workoutTimeCount: TimeInterval = 0.0
    var setTimeCount: TimeInterval = 0.0
    
    var workout: SpinWorkout?
    
    var setNumber: Int = 0
    var setCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setCount = workout?.sets?.count ?? 0
        
        var workoutSeconds: Double = 0.0
        
        for i in 0 ..< setCount {
            let seconds = workout?.sets![i].seconds ?? 0.0
            workoutSeconds += seconds
        }
        
        maxWorkoutTime = workoutSeconds
        
        resetWorkout()
        nextWorkoutSet()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Workouts
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        var titleLabel = ""
        
        if sender.titleLabel?.text == "Start" || sender.titleLabel?.text == "Resume"{
            startTimer()
            if timerPause {
                timerPause = false
            } else {
                nextWorkoutSet()
            }
            
            titleLabel = "Pause"
        } else {
            stopTimer()
            timerPause = true
            
            titleLabel = "Resume"
        }
        
        sender.setTitle(titleLabel, for: .normal)
        sender.setTitle(titleLabel, for: .selected)
        sender.setTitle(titleLabel, for: .highlighted)
        
        sender.sizeToFit()

    }
    
    func nextWorkoutSet() {
        if setNumber >= setCount {
            return
        }
        
        let gear = workout?.sets![setNumber].gear ?? 0
        let cadence = workout?.sets![setNumber].cadence ?? 0
        let seconds = workout?.sets![setNumber].seconds ?? 0.0
        
        maxSetTime = seconds
        
        //setLabel.text = "\(setNumber + 1)"
        
        gearLabel.text = "\(gear)"
        gearLabel.sizeToFit()
        
        cadenceLabel.text = "\(cadence)"
        cadenceLabel.sizeToFit()
        
        if timerCountDown {
            setTimeCount = maxSetTime
        } else {
            setTimeCount = 0.0
        }
        
        if setNumber == 0 {
            workoutTimerLabel.text = timeString(interval: workoutTimeCount, format: "hms")
            setTimerLabel.text = timeString(interval: setTimeCount, format: "hms")
        }
        
    }
    
    func resetWorkout() {
        setNumber = 0
        
        if timerCountDown {
            workoutTimeCount = maxWorkoutTime
        } else {
            workoutTimeCount = 0.0
        }
        
        timerPause = false
        
        let titleLabel = "Start"
        
        startButtonLabel.setTitle(titleLabel, for: .normal)
        startButtonLabel.setTitle(titleLabel, for: .selected)
        startButtonLabel.setTitle(titleLabel, for: .highlighted)
    }

    func startTimer() {
        // prevent more than one timer on the thread
        if !timer.isValid {
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: (#selector(self.timerDidEnd)), userInfo: nil, repeats: true)
        }
        
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    func timeString(interval: TimeInterval, format: String) -> String {
        let ti = Int(interval)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        if format.lowercased() == "hm" {
            return String(format: "%d h %0.2d m", hours, minutes)
        } else {
            return String(format: "%d.%0.2d.%0.2d", hours, minutes, seconds)
        }
    }
    
    @objc func timerDidEnd(timer: Timer) {
        if timerCountDown {
            // timer that counts down
            workoutTimeCount = workoutTimeCount - timeInterval
            setTimeCount = setTimeCount - timeInterval
            if setTimeCount <= 0 {
                if workoutTimeCount <= 0 {
                    timer.invalidate()
                    resetWorkout()
                } else {
                    setNumber += 1
                    nextWorkoutSet()
                }
            } else {
//                workoutTimerLabel.text = timeString(interval: workoutTimeCount, format: "hm")
//                setTimerLabel.text = timeString(interval: setTimeCount, format: "hms")
                let timer1 = timeString(interval: workoutTimeCount, format: "hms")
                let timer2 = timeString(interval: setTimeCount, format: "hms")
                if timer1 != workoutTimerLabel.text && timer2 != setTimerLabel.text {
                    workoutTimerLabel.text = timer1
                    setTimerLabel.text = timer2
                }

            }
        } else {
            // timer that counts up
            workoutTimeCount = workoutTimeCount + timeInterval
            setTimeCount = setTimeCount + timeInterval
            if setTimeCount >= maxSetTime {
                if workoutTimeCount >= maxWorkoutTime {
                    timer.invalidate()
                    resetWorkout()
                } else {
                    setNumber += 1
                    nextWorkoutSet()
                }
            } else {
//                workoutTimerLabel.text = timeString(interval: workoutTimeCount, format: "hm")
//                setTimerLabel.text = timeString(interval: setTimeCount, format: "hms")
                let timer1 = timeString(interval: workoutTimeCount, format: "hms")
                let timer2 = timeString(interval: setTimeCount, format: "hms")
                if timer1 != workoutTimerLabel.text && timer2 != setTimerLabel.text {
                    workoutTimerLabel.text = timer1
                    setTimerLabel.text = timer2
                }

            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
