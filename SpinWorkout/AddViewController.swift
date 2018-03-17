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
    
    @IBOutlet weak var mainCircleView: UIView!
    @IBOutlet weak var gearCircleView: UIView!
    @IBOutlet weak var cadenceCircleView: UIView!
    @IBOutlet weak var durationCircleView: UIView!
    
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
        
        createPickers()
        shapeViewsToCircle()
        
        gearPickerView.isHidden = true
        cadencePickerView.isHidden = true
        hourPickerView.isHidden = true
        minutePickerView.isHidden = true
        secondPickerView.isHidden = true
        
        // hold the position of view based on how the circle view is setup in storyboard
        mainCircleViewX = mainCircleView.frame.origin.x
        gearCircleFinalPosition = gearCircleView.center
        cadenceCircleFinalPosition = cadenceCircleView.center
        durationCircleFinalPosition = durationCircleView.center
        
        // setup starting position of views
        
        mainCircleView.frame.origin.x -= 300
        
        gearCircleView.frame.origin = mainCircleView.center
        cadenceCircleView.frame.origin = mainCircleView.center
        durationCircleView.frame.origin = mainCircleView.center
        
        mainCircleView.alpha = 0
        gearCircleView.alpha = 0
        cadenceCircleView.alpha = 0
        durationCircleView.alpha = 0
        
        workoutTitleLabel.alpha = 0
        
        //
        
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
        
        UIView.animate(withDuration: 2.0, delay: 0, options: .curveEaseOut, animations: {
            self.workoutTitleLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.mainCircleView.frame.origin.x = self.mainCircleViewX
            self.mainCircleView.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 1.7, options: .curveEaseOut, animations: {
            self.gearCircleView.center = self.gearCircleFinalPosition
            self.gearCircleView.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 2.3, options: .curveEaseOut, animations: {
            self.cadenceCircleView.center = self.cadenceCircleFinalPosition
            self.cadenceCircleView.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, delay: 3.2, options: .curveEaseOut, animations: {
            self.durationCircleView.center = self.durationCircleFinalPosition
            self.durationCircleView.alpha = 1.0
        }, completion: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // need this code to hide circleView or else circle will show in the previous view
        mainCircleView.isHidden = true
    }
    
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
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
                        self.setNumberLabel.text = "\(self.setNumber)"
                    }
                })
                alert.addAction(ok)
                
                self.present(alert, animated: true)
                
            }
        }
    }

}

extension AddViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func shapeViewsToCircle() {
        
        let circleViewArray = [mainCircleView, gearCircleView, cadenceCircleView, durationCircleView]
        
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
        
        createGearPicker(centreX: view.center.x, centreY: view.center.y, tag: 1, value: gear)
        createCadencePicker(centreX: view.center.x, centreY: view.center.y, tag: 2, value: cadence)
        createHoursPicker(centreX: view.center.x, centreY: view.center.y, tag: 3, value: hours)
        createMinutesPicker(centreX: view.center.x, centreY: view.center.y, tag: 4, value: minutes)
        createSecondsPicker(centreX: view.center.x, centreY: view.center.y, tag: 5, value: seconds)
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
        
        rotationAngle = -90 * (.pi / 180)
        pickerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        pickerView.frame = CGRect(x: 0 - 75, y: 0, width: view.frame.width + 150, height: 100)
        //pickerView.center = self.view.center
        pickerView.center.x = centreX
        pickerView.center.y = centreY
        
        pickerView.tag = tag
        
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
        return 50
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
        label.font = UIFont.systemFont(ofSize: 30)
        
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
        
        view.transform = CGAffineTransform(rotationAngle: 90 * (.pi / 180))
        
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            gear = Int(gearList[row])!
        case 2:
            cadence = Int(cadenceList[row])!
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
