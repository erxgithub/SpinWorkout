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
    @IBOutlet weak var gearTextField: UITextField!
    @IBOutlet weak var cadenceTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    
    var workoutTitle: String = ""
    var setNumber: Int = 0
    var gear: String = ""
    var cadence: String = ""
    var duration: String = ""

    var delegate: SpinSetDelegate?
    var updateMode: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        workoutTitleLabel.text = workoutTitle
        setNumberLabel.text = "\(setNumber)"
        
        gearTextField.text = gear
        cadenceTextField.text = cadence
        durationTextField.text = duration
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if delegate != nil {
            if let gear = Int(gearTextField.text ?? ""),
            let cadence = Int(cadenceTextField.text ?? ""),
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
