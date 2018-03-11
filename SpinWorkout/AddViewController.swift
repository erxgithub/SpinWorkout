//
//  AddViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit

protocol SpinSetDelegate {
    func updateTableView(set: SpinSet)
}

class AddViewController: UIViewController {

    @IBOutlet weak var workoutTitleLabel: UILabel!
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var gearTextField: UITextField!
    @IBOutlet weak var cadenceTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    
    var workoutTitle: String = ""
    var setNumber:Int = 0

    var delegate : SpinSetDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        workoutTitleLabel.text = workoutTitle
        setNumberLabel.text = "\(setNumber)"
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
                delegate?.updateTableView(set: workoutSet!)
                
                let alert = UIAlertController(title: "Workout Set \(setNumber) added.", message: nil, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                    // If appropriate, configure the new managed object.
                    
                    self.setNumber += 1
                    self.setNumberLabel.text = "\(self.setNumber)"
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
