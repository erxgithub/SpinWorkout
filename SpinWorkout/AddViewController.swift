//
//  AddViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit

protocol SetDelegate {
    func updateTableView(set: SpinSet)
}

class AddViewController: UIViewController {

    var workoutSet: SpinSet?

    var delegate : SetDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if delegate != nil {
            delegate?.updateTableView(set: self.workoutSet!)
            //dismiss the modal
            dismiss(animated: true, completion: nil)
        }
        
        navigationController?.popToRootViewController(animated: true)

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
