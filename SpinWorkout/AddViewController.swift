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
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
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

        // Do any additional setup after loading the view.
        
        workoutTitleLabel.text = workoutTitle
        setNumberLabel.text = "\(setNumber)"
        
        if duration == 0.0 {
            duration = 1.0
        }

        createGearPicker(centreX: view.center.x, centreY: gearLabel.center.y + 40, tag: 1, value: gear)

        createCadencePicker(centreX: view.center.x, centreY: cadenceLabel.center.y + 40, tag: 2, value: cadence)
        
        hours = timeComponent(value: duration, component: "h")
        minutes = timeComponent(value: duration, component: "m")
        seconds = timeComponent(value: duration, component: "s")

        createHoursPicker(centreX: view.center.x, centreY: hoursLabel.center.y + 40, tag: 3, value: hours)
        
        createMinutesPicker(centreX: view.center.x, centreY: minutesLabel.center.y + 40, tag: 4, value: minutes)
        
        createSecondsPicker(centreX: view.center.x, centreY: secondsLabel.center.y + 40, tag: 5, value: seconds)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func createGearPicker(centreX: CGFloat, centreY: CGFloat, tag: Int, value: Int) {
        for i in 1...10 {
            gearList.append("\(i)")
        }

        let index = gearList.index(of: "\(value)") ?? 0
        if index == 0 {
            gear = Int(gearList[0])!
        }

        createCustomPicker(centreX: centreX, centreY: centreY, tag: tag, index: index)
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

        createCustomPicker(centreX: centreX, centreY: centreY, tag: tag, index: index)
    }
    
    func createHoursPicker(centreX: CGFloat, centreY: CGFloat, tag: Int, value: Int) {
        for i in 0...5 {
            hourList.append("\(i)")
        }

        let index = hourList.index(of: "\(value)") ?? 0
        if index == 0 {
            hours = Int(hourList[0])!
        }

        createCustomPicker(centreX: centreX, centreY: centreY, tag: tag, index: index)
    }
    
    func createMinutesPicker(centreX: CGFloat, centreY: CGFloat, tag: Int, value: Int) {
        for i in 0...59 {
            minuteList.append("\(i)")
        }

        let index = minuteList.index(of: "\(value)") ?? 0
        if index == 0 {
            minutes = Int(minuteList[0])!
        }

        createCustomPicker(centreX: centreX, centreY: centreY, tag: tag, index: index)
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

        createCustomPicker(centreX: centreX, centreY: centreY, tag: tag, index: index)
    }
    
    func createCustomPicker(centreX: CGFloat, centreY: CGFloat, tag: Int, index: Int) {
        let pickerView = UIPickerView()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.tag = tag
        
        pickerView.layer.borderColor = UIColor.black.cgColor
        pickerView.layer.borderWidth = 1.5
        
        rotationAngle = -90 * (.pi / 180)
        pickerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        pickerView.frame = CGRect(x: 0 - 75, y: 0, width: view.frame.width + 150, height: 50)
        //pickerView.center = self.view.center
        pickerView.center.x = centreX
        pickerView.center.y = centreY
        
        pickerView.tag = tag
        
        pickerView.selectRow(index, inComponent: 0, animated: true)
        
        self.view.addSubview(pickerView)
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
