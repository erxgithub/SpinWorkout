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
    @IBOutlet weak var durationTextField: UITextField!
    
    var workoutTitle: String = ""
    var setNumber: Int = 0
    var gear: String = ""
    var cadence: String = ""
    var duration: String = ""

    var delegate: SpinSetDelegate?
    var updateMode: Bool = false
    
    // pickers
    
    var gearList: [String] = []
    var gearSelected: String = ""
    
    var cadenceList: [String] = []
    var cadenceSelected: String = ""

    var rotationAngle: CGFloat!
    let width: CGFloat = 50
    let height: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        workoutTitleLabel.text = workoutTitle
        setNumberLabel.text = "\(setNumber)"
        
        if duration == "" {
            duration = "1"
        }

        //gearTextField.text = gear
        //cadenceTextField.text = cadence
        durationTextField.text = duration

        createGearPicker(centreX: view.center.x, centreY: gearLabel.center.y + 40, tag: 1, value: gear)

        createCadencePicker(centreX: view.center.x, centreY: cadenceLabel.center.y + 40, tag: 2, value: cadence)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if delegate != nil {
            if let gear = Int(gear),
            let cadence = Int(cadence),
                let duration = Double(durationTextField.text ?? "") {
                
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
                    // If appropriate, configure the new managed object.
                    
                    if !self.updateMode {
                        self.setNumber += 1
                        self.setNumberLabel.text = "\(self.setNumber)"
                    }
                })
                alert.addAction(ok)
                
                self.present(alert, animated: true)
                
            }

            //dismiss the modal
            //dismiss(animated: true, completion: nil)
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
    
    func createGearPicker(centreX: CGFloat, centreY: CGFloat, tag: Int, value: String) {
        for i in 1...10 {
            gearList.append("\(i)")
        }
        
        createCustomPicker(centreX: centreX, centreY: centreY, tag: tag, value: value)
    }
    
    func createCadencePicker(centreX: CGFloat, centreY: CGFloat, tag: Int, value: String) {
        var i = 50
        while i <= 150 {
            cadenceList.append("\(i)")
            i += 5
        }
        
        createCustomPicker(centreX: centreX, centreY: centreY, tag: tag, value: value)
    }

    func createCustomPicker(centreX: CGFloat, centreY: CGFloat, tag: Int, value: String) {
        let pickerView = UIPickerView()

        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.layer.borderColor = UIColor.black.cgColor
        pickerView.layer.borderWidth = 1.5
        
        rotationAngle = -90 * (.pi / 180)
        pickerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        pickerView.frame = CGRect(x: 0 - 75, y: 0, width: view.frame.width + 150, height: 50)
        //pickerView.center = self.view.center
        pickerView.center.x = centreX
        pickerView.center.y = centreY
        
        pickerView.tag = tag
        
        var index = 0
        
        if tag == 2 {
            index = cadenceList.index(of: value) ?? 0
            if index == 0 {
                cadence = cadenceList[0]
            }
        } else {
            index = gearList.index(of: value) ?? 0
            if index == 0 {
                gear = gearList[0]
            }
        }

        pickerView.selectRow(index, inComponent: 0, animated: true)
        
        self.view.addSubview(pickerView)
        
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 2 {
            return cadenceList.count
        } else {
            return gearList.count
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
        
        if pickerView.tag == 2 {
            label.text = cadenceList[row]
        } else {
            label.text = gearList[row]
        }
        label.adjustsFontSizeToFitWidth = true

        view.addSubview(label)
        
        view.transform = CGAffineTransform(rotationAngle: 90 * (.pi / 180))
        
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 2 {
            cadence = cadenceList[row]
        } else {
            gear = gearList[row]
        }
    }
    
}
