//
//  WorkoutViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit

class WorkoutViewController: UIViewController {
    
    @IBOutlet weak var workoutTitleLabel: UILabel!
    @IBOutlet weak var workoutTimerLabel: UILabel!
    @IBOutlet weak var setTimerLabel: UILabel!
    @IBOutlet weak var gearLabel: UILabel!
    @IBOutlet weak var cadenceLabel: UILabel!
    @IBOutlet weak var nextCadenceLabel: UILabel!
    @IBOutlet weak var nextGearLabel: UILabel!
    @IBOutlet weak var circleContainerView: UIView!
    @IBOutlet weak var currentSetLabel: UILabel!
    
    @IBOutlet weak var cadenceImageView: UIImageView!
    @IBOutlet weak var gearImageView: UIImageView!
    @IBOutlet weak var nextCadenceImageView: UIImageView!
    @IBOutlet weak var nextGearImageView: UIImageView!
    
    var timer = Timer()
    var timerCountDown: Bool = true
    var timerPause: Bool = false
    var timeInterval: TimeInterval = 0.1
    
    var currentTimeElapsed : TimeInterval = 0
    var lastStartTime : Date? = nil
    
    var paused = true
    var firstTime = true
    
    var totalTime: TimeInterval = 0.0 // total of everything
    var currentSetTotalTime: TimeInterval = 0.0 // total duration of each as its currently running
    var totalTimeRemaining: TimeInterval = 0.0 // total of everything remaining
    var setTimeCount: TimeInterval = 0.0 // ??
    
    var ratioRemainingTime: TimeInterval?
    
    var workout: SpinWorkout?
    
    var setIndex: Int = 0
    var setCount: Int = 0
    
    var gradientLayer: CAGradientLayer!
    let shapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workoutTitleLabel.text = workout?.title
        
        createGradientLayer()
        createRingLayer()
        
        circleContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        setCount = workout?.sets?.count ?? 0
        
        var workoutSeconds: Double = 0.0
        
        for i in 0 ..< setCount {
            let seconds = workout?.sets![i].seconds ?? 0.0
            workoutSeconds += seconds
        }
        
        totalTime = workoutSeconds
        
        resetWorkout()
        nextWorkoutSet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Private Methods
    
    @objc private func handleTap() {

        if paused == true {
            
            if firstTime == true {   // only ever fired once when it first starts timer
                firstTime = false
                
                startTimer()
                startAnimation()
                
            } else {
                startTimer()
                resumeAnimation()
            }
            lastStartTime = Date()
            
        } else {
            if let lastStartTime = lastStartTime {
                self.currentTimeElapsed += Date().timeIntervalSince(lastStartTime)
                self.lastStartTime = nil
            }
            
            pauseTimer()
            pauseAnimation()
        }
        paused = !paused
    }
    
    private func pauseTimer() {
        stopTimer()
        pauseAnimation()
    }
    
    private func pauseAnimation() {
        
        ratioRemainingTime = percentElapsedTime()
        
        // remove animation
        
        shapeLayer.removeAllAnimations()
        
        // stroke the circle
        if let ratioRemainingTime = ratioRemainingTime {
            
            let center = circleContainerView.center
            let circularPath = UIBezierPath(arcCenter: center, radius: 145, startAngle: -90.degreesToRadians, endAngle: (-90+360).degreesToRadians, clockwise: true)
            shapeLayer.path = circularPath.cgPath
            shapeLayer.strokeColor = UIColor(red: 214.0/255.0, green: 150.0/255.0, blue: 56.0/255.0, alpha: 1.0).cgColor
            shapeLayer.lineWidth = 10
            shapeLayer.lineCap = kCALineCapRound
            shapeLayer.strokeEnd = CGFloat(1.0 - ratioRemainingTime)
            print("ratioRemainingTime: \(1 - ratioRemainingTime)")
            
        }
    }
    
    private func resumeAnimation() {
        
        if let ratioRemainingTime = ratioRemainingTime {
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            basicAnimation.fromValue = 1 - ratioRemainingTime
            basicAnimation.toValue = 1
            basicAnimation.duration = totalTimeRemaining
            basicAnimation.fillMode = kCAFillModeForwards
            basicAnimation.isRemovedOnCompletion = false
            
            shapeLayer.add(basicAnimation, forKey: "strokeAnimation")
        }
    }
    
    private func startAnimation() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.fromValue = 0
        basicAnimation.toValue = 1
        basicAnimation.duration = totalTime
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "strokeAnimation")
    }
    
    private func transitionImageWithCrossDissolve(imageView: UIImageView, setAttribute: Int) {
            
            UIView.transition(with: imageView, duration: 1, options: .transitionCrossDissolve, animations: {
                
                if imageView == self.gearImageView {
                    
                    imageView.image = UIImage(named: "GEAR\(setAttribute)")
                    
                } else {
                
                    if setAttribute >= 50 && setAttribute <= 66 {
                        imageView.image = UIImage(named: "CADENCE1")
                    } else if setAttribute >= 67 && setAttribute <= 83 {
                        imageView.image = UIImage(named: "CADENCE2")
                    } else if setAttribute >= 84 && setAttribute <= 100 {
                        imageView.image = UIImage(named: "CADENCE3")
                    } else if setAttribute >= 101 && setAttribute <= 117 {
                        imageView.image = UIImage(named: "CADENCE4")
                    } else if setAttribute >= 118 && setAttribute <= 134 {
                        imageView.image = UIImage(named: "CADENCE5")
                    } else {
                        imageView.image = UIImage(named: "CADENCE6")
                    }
                }
            }, completion: nil)
    }
    
    private func transitionImageWithFlip(imageView: UIImageView, setAttribute: Int, nextSetAttribute: Int) {
        
        if setAttribute < nextSetAttribute && imageView.image == UIImage(named: "ARROWDOWN") {
            
            UIView.transition(with: imageView, duration: 1, options: .transitionFlipFromBottom , animations: {
                imageView.image = UIImage(named: "ARROWUP")
            }, completion: nil)
            
        } else if setAttribute > nextSetAttribute && imageView.image == UIImage(named: "ARROWUP") {
            
            UIView.transition(with: imageView, duration: 1, options: .transitionFlipFromTop , animations: {
                imageView.image = UIImage(named: "ARROWDOWN")
            }, completion: nil)
            
        }
    }
    
    private func createRingLayer() {
        
        let center = circleContainerView.center
        
        let trackLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: center, radius: 145, startAngle: -90.degreesToRadians, endAngle: (-90+360).degreesToRadians, clockwise: true)
        
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
    
    private func startTimer() {
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: (#selector(self.timerDidEnd)), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer.invalidate()
    }
    
    
    //MARK: Workouts
    
    func nextWorkoutSet() {
        
        if setIndex >= setCount {
            return
        }
        
        let gear = workout?.sets![setIndex].gear ?? 0
        let cadence = workout?.sets![setIndex].cadence ?? 0
        let seconds = workout?.sets![setIndex].seconds ?? 0.0
        
        gearLabel.text = "\(gear)"
        cadenceLabel.text = "\(cadence)"
        transitionImageWithCrossDissolve(imageView: gearImageView, setAttribute: gear)
        transitionImageWithCrossDissolve(imageView: cadenceImageView, setAttribute: cadence)
        
        if (setIndex + 1) < setCount {
            
            let nextGear = workout?.sets![setIndex + 1 ].gear ?? 0
            let nextCadence = workout?.sets![setIndex + 1].cadence ?? 0
        
            nextGearLabel.text = "\(nextGear)"
            nextCadenceLabel.text = "\(nextCadence)"
            transitionImageWithFlip(imageView: nextGearImageView, setAttribute: gear, nextSetAttribute: nextGear)
            transitionImageWithFlip(imageView: nextCadenceImageView, setAttribute: cadence, nextSetAttribute: nextCadence)
            
        } else {
            nextGearLabel.text = " - "
            nextCadenceLabel.text = " --"
        }
        
        currentSetTotalTime = seconds
        
        currentSetLabel.text = "SET \(setIndex + 1) / \(setCount)"
        
        if timerCountDown {
            setTimeCount = currentSetTotalTime
        } else {
            setTimeCount = 0.0
        }
        
        if setIndex == 0 {
            workoutTimerLabel.text = timeString(interval: totalTimeRemaining, format: "hm")
            setTimerLabel.text = timeString(interval: setTimeCount, format: "hms")
        }
        
    }
    
    func resetWorkout() {
        setIndex = 0
        
        if timerCountDown {
            totalTimeRemaining = totalTime
        } else {
            totalTimeRemaining = 0.0
        }
        
        timerPause = false
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
    
    private func percentElapsedTime()-> TimeInterval {
    
            totalTimeRemaining = (totalTime - currentTimeElapsed)
            return totalTimeRemaining / totalTime
    }
    
    @objc func timerDidEnd(timer: Timer) {
        
        // timer that counts down
        totalTimeRemaining = totalTimeRemaining - timeInterval
        print(totalTimeRemaining)
        
        setTimeCount = setTimeCount - timeInterval
        
        if setTimeCount <= 0 {
            if totalTimeRemaining <= 0 {
                timer.invalidate()
                resetWorkout()
            } else {
                setIndex += 1
                nextWorkoutSet()
            }
        } else {
            workoutTimerLabel.text = timeString(interval: totalTimeRemaining, format: "hm")
            setTimerLabel.text = timeString(interval: setTimeCount, format: "hms")
            
        }
        
        // setTimeCount > 0
        //        else {
        //            // timer that counts up
        //            totalTimeRemaining = totalTimeRemaining + timeInterval
        //            setTimeCount = setTimeCount + timeInterval
        //            if setTimeCount >= currentSetTotalTime {
        //                if totalTimeRemaining >= totalTime {
        //                    timer.invalidate()
        //                    resetWorkout()
        //                } else {
        //                    setIndex += 1
        //                    nextWorkoutSet()
        //                }
        //            } else {
        //                workoutTimerLabel.text = timeString(interval: totalTimeRemaining, format: "hm")
        //                setTimerLabel.text = timeString(interval: setTimeCount, format: "hms")
        //
        //            }
        //        }
    }
    
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}
