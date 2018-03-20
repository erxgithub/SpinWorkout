//
//  AddViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit

protocol SpinSetDelegate {
    func addTableView(set: SpinSet)
    func updateTableView(set: SpinSet, index: Int)
}

class AddViewController: UIViewController {

    @IBOutlet weak var workoutTitleLabel: UILabel!
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var gearLabel: UILabel!
    @IBOutlet weak var cadenceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var saveAndDoneButton: UIButton!
    @IBOutlet weak var workoutElementLabel: UILabel!
    
    @IBOutlet weak var mainCircleView: UIView!
    @IBOutlet weak var gearCircleView: UIView!
    @IBOutlet weak var cadenceCircleView: UIView!
    @IBOutlet weak var durationCircleView: UIView!
    @IBOutlet weak var saveCircleView: UIView!
    
    var gearPickerView: UIPickerView!
    var cadencePickerView: UIPickerView!
    var hourPickerView: UIPickerView!
    var minutePickerView: UIPickerView!
    var secondPickerView: UIPickerView!
    
    var workoutTitle: String = ""
    var setNumber: Int = 0
    var gear: Int = 0
    var cadence: Int = 0
    var duration: Double = 0.0

    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0

    var delegate: SpinSetDelegate?
    var updateMode: Bool = false
    
    var mainCircleViewX: CGFloat!
    var gearCircleFinalPosition: CGPoint!
    var cadenceCircleFinalPosition: CGPoint!
    var durationCircleFinalPosition: CGPoint!
    
    var shapeLayer = CAShapeLayer()
    var hourLabel = UILabel()
    var minuteLabel = UILabel()
    var secondLabel = UILabel()
    
    // pickers
    
    var gearList: [String] = []
    var gearSelected: String = ""
    
    var cadenceList: [String] = []
    var cadenceSelected: String = ""
    
    var hourList: [String] = []
    var hourSelected: String = ""
    
    var minuteList: [String] = []
    var minuteSelected: String = ""
    
    var secondList: [String] = []
    var secondSelected: String = ""

    var rotationAngle: CGFloat!
    let width: CGFloat = 50
    let height: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundLayer = CALayer()
        view.layer.backgroundColor = UIColor(red: 57.0/255.0, green: 61.0/255.0, blue: 84.0/255.0, alpha: 1.0).cgColor
        view.layer.addSublayer(backgroundLayer)
        
        createPickers()
        shapeViewsToCircle()
        createRingLayer()
        hourLabel = createLabel(pickerView: hourPickerView, labelText: "Hour")
        minuteLabel = createLabel(pickerView: minutePickerView, labelText: "Min")
        secondLabel = createLabel(pickerView: secondPickerView, labelText: "Sec")
    
    
        // hold the position of view based on how the circle view is setup in storyboard
        mainCircleViewX = mainCircleView.frame.origin.x
        gearCircleFinalPosition = gearCircleView.center
        cadenceCircleFinalPosition = cadenceCircleView.center
        durationCircleFinalPosition = durationCircleView.center
        
        // setup starting position of views
        
        gearCircleView.frame.origin = mainCircleView.center
        cadenceCircleView.frame.origin = mainCircleView.center
        durationCircleView.frame.origin = mainCircleView.center

        gearCircleView.alpha = 0
        cadenceCircleView.alpha = 0
        durationCircleView.alpha = 0
        saveCircleView.alpha = 0
        
        workoutTitleLabel.alpha = 0
        setNumberLabel.alpha = 0
        gearLabel.alpha = 0
        cadenceLabel.alpha = 0
        durationLabel.alpha = 0
        saveAndDoneButton.alpha = 0
        workoutElementLabel.alpha = 0
        
        if workoutTitle != ""  {
            workoutTitleLabel.text = workoutTitle
        } else {
            workoutTitleLabel.text = "Workout Title"
        }
    
        workoutTitleLabel.sizeToFit()
        setNumberLabel.text = "SET \(setNumber)"
        
        if duration == 0.0 {
            duration = 1.0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        startLayerAnimation()
        
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
            self.workoutTitleLabel.alpha = 1.0
        }, completion: nil)
        
        
        
        UIView.animate(withDuration: 2.0, delay: 0.3, options: .curveEaseOut, animations: {
            self.setNumberLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.gearCircleView.center = self.gearCircleFinalPosition
            self.gearCircleView.alpha = 1.0
            self.gearLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 0.8, options: .curveEaseOut, animations: {
            self.cadenceCircleView.center = self.cadenceCircleFinalPosition
            self.cadenceCircleView.alpha = 1.0
            self.cadenceLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 1.0, options: .curveEaseOut, animations: {
            self.durationCircleView.center = self.durationCircleFinalPosition
            self.durationCircleView.alpha = 1.0
            self.durationLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 2, delay: 1.3, options: .curveEaseOut, animations: {
            self.saveCircleView.alpha = 1.0
            self.saveAndDoneButton.alpha = 1.0
        }, completion: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // need these code to hide circle or else circle will show in the previous view when user clicks back
        shapeLayer.strokeColor = UIColor.clear.cgColor
        saveCircleView.isHidden = true
        cadenceCircleView.isHidden = true
        gearCircleView.isHidden = true
        durationCircleView.isHidden = true
    }
    
    
    @IBAction func gearCircleViewTapped(_ sender: UITapGestureRecognizer) {
        
        // FADE OUT
        gearCircleView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.gearCircleView.center = self.mainCircleView.center
            self.gearLabel.alpha = 0
            self.setNumberLabel.alpha = 0
            self.gearCircleView.transform = CGAffineTransform(scaleX: 3, y: 3)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseIn, animations: {
            self.cadenceCircleView.center = self.mainCircleView.center
            self.cadenceCircleView.alpha = 0
            self.cadenceLabel.alpha = 0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 0.5, options: .curveEaseIn, animations: {
            self.durationCircleView.center = self.mainCircleView.center
            self.durationCircleView.alpha = 0
            self.durationLabel.alpha = 0
            self.saveAndDoneButton.alpha = 0
        }, completion: nil)
        
        // FADE IN
        UIView.animate(withDuration: 0.5, delay: 0.75, options: .curveEaseIn, animations: {
            
            self.gearPickerView.alpha = 1.0
            self.saveAndDoneButton.setTitle("DONE", for: .normal)
            self.workoutElementLabel.text = "GEAR"
            self.saveAndDoneButton.sizeToFit()
            self.saveAndDoneButton.alpha = 1.0
            self.shapeLayer.isHidden = true
            self.workoutElementLabel.alpha = 1.0
            
        }, completion: nil)
    }
    
    @IBAction func cadenceCircleViewTapped(_ sender: UITapGestureRecognizer) {
        
        // FADE OUT
        cadenceCircleView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.cadenceCircleView.center = self.mainCircleView.center
            self.cadenceLabel.alpha = 0
            self.setNumberLabel.alpha = 0
            self.cadenceCircleView.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseIn, animations: {
            self.gearCircleView.center = self.mainCircleView.center
            self.gearCircleView.alpha = 0
            self.gearLabel.alpha = 0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 0.5, options: .curveEaseIn, animations: {
            self.durationCircleView.center = self.mainCircleView.center
            self.durationCircleView.alpha = 0
            self.durationLabel.alpha = 0
            self.saveAndDoneButton.alpha = 0
        }, completion: nil)
        
        // FADE IN
         self.workoutElementLabel.frame.origin.x -= 20 // adjust label to give space for picker
        
        UIView.animate(withDuration: 0.5, delay: 0.75, options: .curveEaseIn, animations: {
            
            self.cadencePickerView.alpha = 1.0
            self.saveAndDoneButton.setTitle("DONE", for: .normal)
            self.workoutElementLabel.text = "CADENCE"
            self.saveAndDoneButton.sizeToFit()
            self.saveAndDoneButton.alpha = 1.0
            self.workoutElementLabel.alpha = 1.0
            self.shapeLayer.isHidden = true
        }, completion: nil)
    }
    
    @IBAction func durationCircleViewTapped(_ sender: UITapGestureRecognizer) {
        
        // FADE OUT
        durationCircleView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            self.durationCircleView.center = self.mainCircleView.center
            self.durationLabel.alpha = 0
            self.setNumberLabel.alpha = 0
            self.durationCircleView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 0.25, options: .curveEaseIn, animations: {
            self.gearCircleView.center = self.mainCircleView.center
            self.gearCircleView.alpha = 0
            self.gearLabel.alpha = 0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 0.5, options: .curveEaseIn, animations: {
            self.cadenceCircleView.center = self.mainCircleView.center
            self.cadenceCircleView.alpha = 0
            self.cadenceLabel.alpha = 0
        }, completion: nil)
        
        // FADE IN
         self.workoutElementLabel.frame.origin.x -= 30 // adjust label to give space for picker
        
        UIView.animate(withDuration: 0.5, delay: 0.75, options: .curveEaseIn, animations: {
            
            self.saveAndDoneButton.setTitle("DONE", for: .normal)
            self.workoutElementLabel.text = "DURATION"
            self.saveAndDoneButton.sizeToFit()
            self.saveAndDoneButton.alpha = 1.0
            self.workoutElementLabel.alpha = 1.0
            self.shapeLayer.isHidden = true
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 1, options: .curveEaseIn, animations: {
            self.hourPickerView.alpha = 1.0
            self.hourLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 1.2, options: .curveEaseIn, animations: {
            self.minutePickerView.alpha = 1.0
            self.minuteLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: 1.4, options: .curveEaseIn, animations: {
            self.secondPickerView.alpha = 1.0
            self.secondLabel.alpha = 1.0
        }, completion: nil)
    }
    
    
    @IBAction func SaveAndDoneButtonTapped(_ sender: UIButton) {
        
        switch saveAndDoneButton.titleLabel?.text {
        case "DONE"?:
            
            if gearCircleView.transform != CGAffineTransform.identity {
                
                gearCircleView.isUserInteractionEnabled = true
                if gearLabel.text == "GEAR" {
                    gearLabel.text = "1"
                }
                
                //FADE OUT
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.gearPickerView.alpha = 0
                    self.workoutElementLabel.alpha = 0
                    self.saveAndDoneButton.alpha = 0
                }, completion: { (true) in
                    self.shapeLayer.isHidden = false
                })
                
                //FADE IN
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                    self.gearCircleView.transform = CGAffineTransform.identity
                    self.gearCircleView.center = self.gearCircleFinalPosition
                    self.gearCircleView.alpha = 1.0
                    self.gearLabel.font = UIFont(name: self.gearLabel.font.fontName, size: 53)
                    self.gearLabel.sizeToFit()
                    self.gearLabel.alpha = 1.0
                }, completion: nil)
                
                UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                    self.cadenceCircleView.center = self.cadenceCircleFinalPosition
                    self.cadenceCircleView.alpha = 1.0
                    self.cadenceLabel.alpha = 1.0
                }, completion: nil)
                
                UIView.animate(withDuration: 0.5, delay: 0.8, options: .curveEaseOut, animations: {
                    self.durationCircleView.center = self.durationCircleFinalPosition
                    self.durationCircleView.alpha = 1.0
                    self.durationLabel.alpha = 1.0
                    self.setNumberLabel.alpha = 1.0
                    self.saveAndDoneButton.setTitle("SAVE", for: .normal)
                    self.saveAndDoneButton.alpha = 1.0
                }, completion: nil)
            }
            
            if cadenceCircleView.transform != CGAffineTransform.identity {
                
                cadenceCircleView.isUserInteractionEnabled = true
                if cadenceLabel.text == "CADENCE" {
                    cadenceLabel.text = "50"
                }
                
                //FADE OUT
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.cadencePickerView.alpha = 0
                    self.workoutElementLabel.alpha = 0
                    self.saveAndDoneButton.alpha = 0
                }, completion: { (true) in
                    self.shapeLayer.isHidden = false
                })
                
                //FADE IN
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                    self.cadenceCircleView.transform = CGAffineTransform.identity
                    self.cadenceCircleView.center = self.cadenceCircleFinalPosition
                    self.cadenceCircleView.alpha = 1.0
                    self.cadenceLabel.font = UIFont(name: self.gearLabel.font.fontName, size: 53)
                    self.cadenceLabel.sizeToFit()
                    self.cadenceLabel.alpha = 1.0
                }, completion: nil)
                
                UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                    self.gearCircleView.center = self.gearCircleFinalPosition
                    self.gearCircleView.alpha = 1.0
                    self.gearLabel.alpha = 1.0
                }, completion: nil)
                
                UIView.animate(withDuration: 0.5, delay: 0.8, options: .curveEaseOut, animations: {
                    self.durationCircleView.center = self.durationCircleFinalPosition
                    self.durationCircleView.alpha = 1.0
                    self.durationLabel.alpha = 1.0
                    self.setNumberLabel.alpha = 1.0
                    self.saveAndDoneButton.setTitle("SAVE", for: .normal)
                    self.saveAndDoneButton.alpha = 1.0
                }, completion: { (true) in
                    self.workoutElementLabel.frame.origin.x += 20 // adjust label back to start position
                })
            }
            
            if durationCircleView.transform != CGAffineTransform.identity {
                
                durationCircleView.isUserInteractionEnabled = true
                
                // FADE OUT
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.hourPickerView.alpha = 0
                    self.hourLabel.alpha = 0
                    self.minutePickerView.alpha = 0
                    self.minuteLabel.alpha = 0
                    self.secondPickerView.alpha = 0
                    self.secondLabel.alpha = 0
                    self.workoutElementLabel.alpha = 0
                    self.saveAndDoneButton.alpha = 0
                }, completion: { (true) in
                    self.shapeLayer.isHidden = false
                })
                
                // FADE IN
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                    self.durationCircleView.transform = CGAffineTransform.identity
                    self.durationCircleView.center = self.durationCircleFinalPosition
                    self.durationCircleView.alpha = 1.0
                    self.durationLabel.font = UIFont(name: self.gearLabel.font.fontName, size: 30)
                    self.durationLabel.sizeToFit()
                    self.durationLabel.text = "\(self.hours)h \(self.minutes)m \(self.seconds)s"
                    self.durationLabel.alpha = 1.0
                }, completion: nil)
                
                UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                    self.gearCircleView.center = self.gearCircleFinalPosition
                    self.gearCircleView.alpha = 1.0
                    self.gearLabel.alpha = 1.0
                }, completion: nil)
                
                UIView.animate(withDuration: 0.5, delay: 0.8, options: .curveEaseOut, animations: {
                    self.cadenceCircleView.center = self.cadenceCircleFinalPosition
                    self.cadenceCircleView.alpha = 1.0
                    self.cadenceLabel.alpha = 1.0
                    self.setNumberLabel.alpha = 1.0
                    self.saveAndDoneButton.setTitle("SAVE", for: .normal)
                    self.saveAndDoneButton.alpha = 1.0
                }, completion: { (true) in
                    self.workoutElementLabel.frame.origin.x += 30 // adjust label back to start position
                })
                
            }
            

        default:
            if delegate != nil {
                if gear > 0 && cadence > 0 && duration > 0.0 {
                    let duration = timeValue(hours: hours, minutes: minutes, seconds: seconds)
                    
                    let workoutSet = SpinSet(sequence: setNumber, gear: gear, cadence: cadence, seconds: duration)
                    
                    var alertTitle = ""
                    
                    if updateMode {
                        delegate?.updateTableView(set: workoutSet!, index: self.setNumber - 1)
                        alertTitle = "Workout set \(setNumber) updated."
                    } else {
                        delegate?.addTableView(set: workoutSet!)
                        alertTitle = "Workout set \(setNumber) added."
                    }
                    
                    let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
                    
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                        if !self.updateMode {
                            self.setNumber += 1
                            
                            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                                self.setNumberLabel.alpha = 0
                                
                            }, completion: { (true) in
                                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                                    self.setNumberLabel.text = "SET \(self.setNumber)"
                                    self.setNumberLabel.alpha = 1.0
                                }, completion: nil)
                                
                            })
                        }
                    })
                    alert.addAction(ok)
                    
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func createRingLayer() {
        
        let center = mainCircleView.center
        
        let circularPath = UIBezierPath(arcCenter: center, radius: mainCircleView.frame.width / 2, startAngle: -.pi, endAngle: .pi * 2, clockwise: true)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor(red: 214.0/255.0, green: 150.0/255.0, blue: 56.0/255.0, alpha: 1.0).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 15
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    private func startLayerAnimation() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.fromValue = 0
        basicAnimation.toValue = 1
        basicAnimation.duration = 1.5
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "layerAnimation")
    }
    
    private func createAttributedString(string: String) -> NSMutableAttributedString {
        
        let mutableString = NSMutableAttributedString(
            string: string,
            attributes: [NSAttributedStringKey.font:UIFont(
                name: "UniversLT-CondensedBold",
                size: 17.0)!])
        mutableString.addAttribute(NSAttributedStringKey.font, value: UIFont(
            name: "UniversLT-CondensedBold",
            size: 42.0)!, range: NSRange(location: 0, length: 1))
        
        return mutableString
    }
    
    private func createLabel(pickerView: UIPickerView, labelText: String) -> UILabel {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        
        label.center = CGPoint(x: pickerView.frame.origin.x + pickerView.frame.width / 2,
                               y: pickerView.frame.origin.y + label.frame.height - 70)
        label.textAlignment = .center
        label.textColor = .white
        label.alpha = 0
        label.attributedText = createAttributedString(string: labelText)
        view.addSubview(label)
        
        return label
    }

}

extension AddViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func shapeViewsToCircle() {
        
        let circleViewArray = [gearCircleView, cadenceCircleView, durationCircleView, saveCircleView]
        for element in circleViewArray {
            if let element = element {
                element.layer.cornerRadius = element.frame.size.width / 2
                element.clipsToBounds = true
            }
        }
    }
    
    func createPickers() {
        
        hours = timeComponent(value: duration, component: "h")
        minutes = timeComponent(value: duration, component: "m")
        seconds = timeComponent(value: duration, component: "s")
        
        let workoutElementLabelCentreY = workoutElementLabel.frame.origin.y + workoutElementLabel.frame.height / 2
        
        createGearPicker(centreX: view.center.x + 100, centreY: workoutElementLabelCentreY, tag: 1, value: gear)
        createCadencePicker(centreX: view.center.x + 100, centreY: workoutElementLabelCentreY, tag: 2, value: cadence)
        createHoursPicker(centreX: view.center.x + 20 , centreY: view.center.y/1.35, tag: 3, value: hours)
        createMinutesPicker(centreX: view.center.x + 80, centreY: workoutElementLabel.frame.origin.y, tag: 4, value: minutes)
        createSecondsPicker(centreX: view.center.x + 142, centreY: view.center.y*1.22, tag: 5, value: seconds)
    }
    
    func createGearPicker(centreX: CGFloat, centreY: CGFloat, tag: Int, value: Int) {
        for i in 1...10 {
            gearList.append("\(i)")
        }

        let index = gearList.index(of: "\(value)") ?? 0
        if index == 0 {
            gear = Int(gearList[0])!
        }

        gearPickerView = createCustomPicker(centreX: centreX, centreY: centreY, tag: tag, index: index)
    }
    
    func createCadencePicker(centreX: CGFloat, centreY: CGFloat, tag: Int, value: Int) {
        var i = 50
        while i <= 150 {
            cadenceList.append("\(i)")
            i += 5
        }

        let index = cadenceList.index(of: "\(value)") ?? 0
        if index == 0 {
            cadence = Int(cadenceList[0])!
        }

        cadencePickerView = createCustomPicker(centreX: centreX, centreY: centreY, tag: tag, index: index)
    }
    
    func createHoursPicker(centreX: CGFloat, centreY: CGFloat, tag: Int, value: Int) {
        for i in 0...5 {
            hourList.append("\(i)")
        }

        let index = hourList.index(of: "\(value)") ?? 0
        if index == 0 {
            hours = Int(hourList[0])!
        }

        hourPickerView = createCustomPicker(centreX: centreX, centreY: centreY, tag: tag, index: index)
    }
    
    func createMinutesPicker(centreX: CGFloat, centreY: CGFloat, tag: Int, value: Int) {
        for i in 0...59 {
            minuteList.append("\(i)")
        }

        let index = minuteList.index(of: "\(value)") ?? 0
        if index == 0 {
            minutes = Int(minuteList[0])!
        }

        minutePickerView = createCustomPicker(centreX: centreX, centreY: centreY, tag: tag, index: index)
    }
    
    func createSecondsPicker(centreX: CGFloat, centreY: CGFloat, tag: Int, value: Int) {
        var i = 0
        while i <= 55 {
            secondList.append("\(i)")
            i += 5
        }

        let index = secondList.index(of: "\(value)") ?? 0
        if index == 0 {
            seconds = Int(secondList[0])!
        }

        secondPickerView = createCustomPicker(centreX: centreX, centreY: centreY, tag: tag, index: index)
    }
    
    func createCustomPicker(centreX: CGFloat, centreY: CGFloat, tag: Int, index: Int) -> UIPickerView {
        let pickerView = UIPickerView()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.tag = tag
        
        if pickerView.tag == 1 || pickerView.tag == 2 {
            pickerView.frame = CGRect(x: 0 - 75, y: 0, width: view.frame.width / 5, height: 450)
        } else {
            pickerView.frame = CGRect(x: 0 - 75, y: 0, width: 50, height: 200)
        }
        pickerView.center.x = centreX
        pickerView.center.y = centreY
        pickerView.alpha = 0
        
        pickerView.selectRow(index, inComponent: 0, animated: true)
        
        self.view.addSubview(pickerView)
        
        return pickerView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return gearList.count
        case 2:
            return cadenceList.count
        case 3:
            return hourList.count
        case 4:
            return minuteList.count
        case 5:
            return secondList.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        if pickerView.tag == 1 || pickerView.tag == 2 {
            return 75
        } else {
            
        return 45
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        label.textAlignment = .center
        if pickerView.tag == 1 || pickerView.tag == 2 {
            label.font = UIFont(name: "UniversLT-CondensedBold", size: 58)
        } else {
             label.font = UIFont(name: "UniversLT-CondensedBold", size: 30)
        }
        label.textColor = UIColor.white
        
        switch pickerView.tag {
        case 1:
            label.text = gearList[row]
        case 2:
            label.text = cadenceList[row]
        case 3:
            label.text = hourList[row]
        case 4:
            label.text = minuteList[row]
        case 5:
            label.text = secondList[row]
        default:
            label.text = ""
        }
        
        label.adjustsFontSizeToFitWidth = true
        
        view.addSubview(label)
        
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            gear = Int(gearList[row])!
            gearLabel.text = String(gear)
        case 2:
            cadence = Int(cadenceList[row])!
            cadenceLabel.text = String(cadence)
        case 3:
            hours = Int(hourList[row])!
        case 4:
            minutes = Int(minuteList[row])!
        case 5:
            seconds = Int(secondList[row])!
        default:
            print("Tag not recognized.")
        }
    }

}
