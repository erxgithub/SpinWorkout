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
    @IBOutlet weak var nextCadenceLabel: UILabel!
    @IBOutlet weak var nextGearLabel: UILabel!
    @IBOutlet weak var circleContainerView: UIView!
    @IBOutlet weak var currentSetLabel: UILabel!
    
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
    
    var gradientLayer: CAGradientLayer!
    let shapeLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createGradientLayer()
        createRingLayer()
        
        circleContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
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
    
    // MARK: Private Methods
    
    @objc private func handleTap() {
    
            ///////// start stroke animation
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            basicAnimation.fromValue = 0
            basicAnimation.toValue = 1
            basicAnimation.duration = maxWorkoutTime
            print(maxWorkoutTime)
            basicAnimation.fillMode = kCAFillModeForwards
            basicAnimation.isRemovedOnCompletion = false
            
            shapeLayer.add(basicAnimation, forKey: "strokeAnimation")
        
        /////////
        
        timerPause = !timerPause
        
        if timerPause == true {
            startTimer()
        } else {
            stopTimer()
        }
    
    }

    private func createRingLayer() {
        
        let center = circleContainerView.center

        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: center, radius: 145, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor(red: 214.0/255.0, green: 150.0/255.0, blue: 56.0/255.0, alpha: 0.25).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 10
        trackLayer.lineCap = kCALineCapRound
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor(red: 214.0/255.0, green: 150.0/255.0, blue: 56.0/255.0, alpha: 1.0).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.strokeEnd = 0
    
        view.layer.addSublayer(shapeLayer)
    }
    
    private func createGradientLayer() {
        
        let topColor = UIColor(red: 37.0/255.0, green: 48.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
        let middleColor = UIColor (red: 61.0/255.0, green: 64.0/255.0, blue: 86.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 37.0/255.0, green: 48.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [topColor, middleColor, bottomColor]
        gradientLayer.locations = [0.0, 0.75]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    //MARK: Workouts
    
    @IBAction func startButtonTapped(_ sender: UIButton) {

//        /////// start stroke animation
//        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
//        basicAnimation.fromValue = 0
//        basicAnimation.toValue = 1
//        basicAnimation.duration = maxWorkoutTime
//        basicAnimation.fillMode = kCAFillModeForwards
//        basicAnimation.isRemovedOnCompletion = false
//
//        shapeLayer.add(basicAnimation, forKey: "strokeAnimation")
//        ///////
//
//        var titleLabel = ""
//
//        if sender.titleLabel?.text == "Start" || sender.titleLabel?.text == "Resume"{
//            startTimer()
//            if timerPause {
//                timerPause = false
//
//            } else {
//                nextWorkoutSet()
//
//            }
//
//            titleLabel = "Pause"
//        } else {
//            stopTimer()
//
//            timerPause = true
//
//            titleLabel = "Resume"
//        }
//
//        sender.setTitle(titleLabel, for: .normal)
//        sender.setTitle(titleLabel, for: .selected)
//        sender.setTitle(titleLabel, for: .highlighted)
//
//        sender.sizeToFit()

    }
    
    func nextWorkoutSet() {
        
        if setNumber >= setCount {
            return
        }
        
        let gear = workout?.sets![setNumber].gear ?? 0
        let cadence = workout?.sets![setNumber].cadence ?? 0
        let seconds = workout?.sets![setNumber].seconds ?? 0.0
        
        
        if (setNumber + 1) < setCount {
            
            let nextGear = workout?.sets![setNumber + 1 ].gear ?? 0
            let nextCadence = workout?.sets![setNumber + 1].cadence ?? 0
            
            nextGearLabel.text = "\(nextGear)"
            nextCadenceLabel.text = "\(nextCadence)"
    
        } else {
            nextGearLabel.text = " - "
            nextCadenceLabel.text = " --"
        }

        maxSetTime = seconds
        
        gearLabel.text = "\(gear)"
        gearLabel.sizeToFit()
        
        cadenceLabel.text = "\(cadence)"
        cadenceLabel.sizeToFit()
       
        currentSetLabel.text = "SET \(setNumber + 1) / \(setCount)"
        
        if timerCountDown {
            setTimeCount = maxSetTime
        } else {
            setTimeCount = 0.0
        }
        
        if setNumber == 0 {
            workoutTimerLabel.text = timeString(interval: workoutTimeCount, format: "hm")
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
        
        //        let titleLabel = "Start"
        //
        //        startButtonLabel.setTitle(titleLabel, for: .normal)
        //        startButtonLabel.setTitle(titleLabel, for: .selected)
        //        startButtonLabel.setTitle(titleLabel, for: .highlighted)
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
                workoutTimerLabel.text = timeString(interval: workoutTimeCount, format: "hm")
                setTimerLabel.text = timeString(interval: setTimeCount, format: "hms")
//                let timer1 = timeString(interval: workoutTimeCount, format: "hms")
//                let timer2 = timeString(interval: setTimeCount, format: "hms")
//                if timer1 != workoutTimerLabel.text && timer2 != setTimerLabel.text {
//                    workoutTimerLabel.text = timer1
//                    setTimerLabel.text = timer2
//                }

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
                workoutTimerLabel.text = timeString(interval: workoutTimeCount, format: "hm")
                setTimerLabel.text = timeString(interval: setTimeCount, format: "hms")
//                let timer1 = timeString(interval: workoutTimeCount, format: "hms")
//                let timer2 = timeString(interval: setTimeCount, format: "hms")
//                if timer1 != workoutTimerLabel.text && timer2 != setTimerLabel.text {
//                    workoutTimerLabel.text = timer1
//                    setTimerLabel.text = timer2
//                }

            }
        }
    }

}
