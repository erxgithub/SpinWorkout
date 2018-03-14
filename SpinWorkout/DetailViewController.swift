//
//  DetailViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit

protocol WorkoutDelegate {
    func addTableView(spinWorkout: SpinWorkout)
    func updateTableView(spinWorkout: SpinWorkout, index: Int)
}

class DetailViewController: UIViewController, SpinSetDelegate {
    
    @IBOutlet weak var workoutTitleTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalDurationLabel: UILabel!
    
    var workout: SpinWorkout?
    var sets: [SpinSet]? = []

    var delegate: WorkoutDelegate?
    var updateMode: Bool = false
    var workoutNumber: Int = 0
    
    var addingWorkoutSets: Bool = false
    var editingWorkoutSets: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if workout != nil {
            workoutTitleTextField.text = workout?.title
            sets = workout?.sets
            sets?.sort(by: {$0.sequence < $1.sequence})
        }

        let duration = self.sets?.reduce(0) { $0 + $1.seconds }
        totalDurationLabel.text = "\(duration ?? 0.0)"
        
        addingWorkoutSets = false
        editingWorkoutSets = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if addingWorkoutSets || editingWorkoutSets {
            addingWorkoutSets = false
            editingWorkoutSets = false
        } else {
            if delegate != nil {
                let workoutTitle = workoutTitleTextField.text
                let titleLength = workoutTitle?.count ?? 0
                if titleLength > 0 {
                    let workout = SpinWorkout(title: workoutTitle, sets: sets)
                    if updateMode {
                        delegate?.updateTableView(spinWorkout: workout!, index: workoutNumber)
                    } else {
                        delegate?.addTableView(spinWorkout: workout!)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if !self.tableView.isEditing {
            self.tableView.isEditing = true
        } else {
            self.tableView.isEditing = false
        }
    }
    
    //    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
//        if delegate != nil {
//            let workoutTitle = workoutTitleTextField.text
//            let titleLength = workoutTitle?.count ?? 0
//            if titleLength > 0 {
//                let workout = SpinWorkout(title: workoutTitle, sets: sets)
//                if updateMode {
//                    delegate?.updateTableView(spinWorkout: workout!, index: workoutNumber)
//                } else {
//                    delegate?.addTableView(spinWorkout: workout!)
//                }
//
//                let alert = UIAlertController(title: "Workout saved.", message: nil, preferredStyle: .alert)
//
//                let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
//                    // If appropriate, configure the new managed object.
//
//                    //dismiss the modal
//                    self.dismiss(animated: true, completion: nil)
//                    self.navigationController?.popToRootViewController(animated: true)
//
//                })
//                alert.addAction(ok)
//
//                self.present(alert, animated: true)
//
//            }
//
//        }
//
//    }
    
    func addTableView(set: SpinSet) {
        self.sets?.append(set)
        tableView.reloadData()

        let duration = self.sets?.reduce(0) { $0 + $1.seconds }
        totalDurationLabel.text = "\(duration ?? 0.0)"
    }
    
    func updateTableView(set: SpinSet, index: Int) {
        if index < 0 || index >= self.sets!.count {
            return
        }
        
        self.sets![index].gear = set.gear
        self.sets![index].cadence = set.cadence
        self.sets![index].seconds = set.seconds

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
        if segue.identifier == "addSet" {
            addingWorkoutSets = true
            guard let addViewController = segue.destination as? AddViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            addViewController.delegate = self
            addViewController.setNumber = (sets?.count ?? 0) + 1
            addViewController.updateMode = false
            
            addViewController.workoutTitle = workoutTitleTextField.text ?? ""

        } else if segue.identifier == "editSet" {
            editingWorkoutSets = true
            guard let addViewController = segue.destination as? AddViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let setCell = sender as? DetailTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: setCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedSet = sets![indexPath.row]

            addViewController.delegate = self
            addViewController.setNumber = selectedSet.sequence
            addViewController.updateMode = true

            addViewController.workoutTitle = workoutTitleTextField.text ?? ""
            addViewController.gear = "\(selectedSet.gear)"
            addViewController.cadence = "\(selectedSet.cadence)"
            addViewController.duration = "\(selectedSet.seconds)"
            
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
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { (UITableViewRowAction, IndexPath) -> Void in
            self.performSegue(withIdentifier: "editSet", sender: tableView.cellForRow(at: indexPath))
            
        })
        editAction.backgroundColor = UIColor.blue
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete", handler: { (UITableViewRowAction, IndexPath) -> Void in
            self.sets?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        deleteAction.backgroundColor = UIColor.red
        
        if tableView.isEditing {
            return [deleteAction]
        } else {
            return [deleteAction, editAction]
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sets?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.sets![sourceIndexPath.row]
        sets?.remove(at: sourceIndexPath.row)
        sets?.insert(movedObject, at: destinationIndexPath.row)
        
        let count = sets?.count ?? 0
        for i in 0..<count {
            sets![i].sequence = i + 1
        }
        
        tableView.reloadData()
        
    }

}
