//
//  DetailViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit

protocol WorkoutDelegate {
    func updateTableView(workout: SpinWorkout)
}

class DetailViewController: UIViewController, SpinSetDelegate {
    
    @IBOutlet weak var workoutTitleTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalDurationLabel: UILabel!
    
    var workout: SpinWorkout?
    var sets: [SpinSet]? = []

    var delegate : WorkoutDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let duration = self.sets?.reduce(0) { $0 + $1.seconds }
        totalDurationLabel.text = "\(duration ?? 0.0)"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if delegate != nil {
            let workoutTitle = workoutTitleTextField.text
            let titleLength = workoutTitle?.count ?? 0
            if titleLength > 0 {
                let workout = SpinWorkout(title: workoutTitle, sets: sets)
                delegate?.updateTableView(workout: workout!)
                
                let alert = UIAlertController(title: "Workout saved.", message: nil, preferredStyle: .alert)
                
                let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                    // If appropriate, configure the new managed object.
                    
                    //dismiss the modal
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                    
                })
                alert.addAction(ok)
                
                self.present(alert, animated: true)

            }
            
        }
        
    }
    
    func updateTableView(set: SpinSet) {
        print("updateTableView")
        self.sets?.append(set)
        tableView.reloadData()

        let duration = self.sets?.reduce(0) { $0 + $1.seconds }
        totalDurationLabel.text = "\(duration ?? 0.0)"
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "addSets" {
            //let controller = segue.destination as! WorkoutViewController
            //controller.delegate = self
            
            guard let addViewController = segue.destination as? AddViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
//            guard let setCell = sender as? DetailTableViewCell else {
//                fatalError("Unexpected sender: \(String(describing: sender))")
//            }
            
//            guard let indexPath = tableView.indexPath(for: setCell) else {
//                fatalError("The selected cell is not being displayed by the table")
//            }
            
            //let selectedSet = sets![indexPath.row]
            //addViewController.workoutTitleLabel.text = workoutTitleTextField.text
            
            addViewController.delegate = self
            addViewController.workoutTitle = workoutTitleTextField.text ?? ""
            addViewController.setNumber = (sets?.count ?? 0) + 1

        }
    }

}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets!.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetCell", for: indexPath) as? DetailTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UITableViewCell.")
        }
        
        cell.setLabel.text = "\(sets?[indexPath.row].sequence ?? 0)"
        cell.gearLabel.text = "\(sets?[indexPath.row].gear ?? 0)"
        cell.cadenceLabel.text = "\(sets?[indexPath.row].cadence ?? 0)"
        cell.durationLabel.text = "\(sets?[indexPath.row].seconds ?? 0.0)"
        
        // Fetches the appropriate meal for the data source layout.
        //let workoutSet = sets![indexPath.row]
        
        return cell
        
    }
    
}
