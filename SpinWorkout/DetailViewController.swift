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

class DetailViewController: UIViewController, SpinSetDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var workoutTitleTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalDurationLabel: UILabel!

    var workout: SpinWorkout?
    var sets: [SpinSet]? = []

    var delegate: WorkoutDelegate?
    var updateMode: Bool = false
    var workoutNumber: Int = 0
    var gradientLayer: CAGradientLayer!

    fileprivate var sourceIndexPath: IndexPath?
    fileprivate var snapshot: UIView?
    
    var addingWorkoutSets: Bool = false
    var editingWorkoutSets: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        workoutTitleTextField.delegate = self
        createGradientLayer()
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: workoutTitleTextField.frame.size.height - width, width:  workoutTitleTextField.frame.size.width, height: workoutTitleTextField.frame.size.height)
        
        border.borderWidth = width
        workoutTitleTextField.layer.addSublayer(border)
        workoutTitleTextField.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(longPress:)))
        self.tableView.addGestureRecognizer(longPress)
        
        if workout != nil {
            workoutTitleTextField.text = workout?.title
            sets = workout?.sets
            sets?.sort(by: {$0.sequence < $1.sequence})
        }

        let duration = self.sets?.reduce(0) { $0 + $1.seconds }
        let durationStringFormat = timeString(interval: duration ?? 0.0, format: "")
        totalDurationLabel.text = "Total Duration - \(durationStringFormat)"
        totalDurationLabel.sizeToFit()

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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        workoutTitleTextField.resignFirstResponder()
        return false
    }
    
    func createGradientLayer() {
        
        let topColor = UIColor(red: 53.0/255.0, green: 72.0/255.0, blue: 118.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 32.0/255.0, green: 41.0/255.0, blue: 62.0/255.0, alpha: 1.0).cgColor
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [topColor, bottomColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc func longPressGestureRecognized(longPress: UILongPressGestureRecognizer) {
        let state = longPress.state
        let location = longPress.location(in: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: location) else {
            tableView.reloadData()
            self.cleanup()
            return
        }
        switch state {
        case .began:
            sourceIndexPath = indexPath
            guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
            // take a snapshot of the selected row using helper method
            snapshot = self.customSnapshotFromView(inputView: cell)
            guard let snapshot = self.snapshot else { return }
            var center = cell.center
            snapshot.center = center
            snapshot.alpha = 0.0
            self.tableView.addSubview(snapshot)
            UIView.animate(withDuration: 0.25, animations: {
                center.y = location.y
                snapshot.center = center
                snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                snapshot.alpha = 0.98
                cell.alpha = 0.0
            }, completion: { (finished) in
                cell.isHidden = true
            })
            break
        case .changed:
            guard let snapshot = self.snapshot else {
                return
            }
            var center = snapshot.center
            center.y = location.y
            snapshot.center = center
            guard let sourceIndexPath = self.sourceIndexPath  else {
                return
            }
            if indexPath != sourceIndexPath {
                sets?.swapAt(indexPath.row, sourceIndexPath.row)
                self.tableView.moveRow(at: sourceIndexPath, to: indexPath)
                self.sourceIndexPath = indexPath

                let count = sets?.count ?? 0
                for i in 0..<count {
                    sets![i].sequence = i + 1
                }

                tableView.reloadData()

            }
            break
        default:
            guard let cell = self.tableView.cellForRow(at: indexPath) else {
                return
            }
            guard let snapshot = self.snapshot else {
                return
            }
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: {
                snapshot.center = cell.center
                snapshot.transform = CGAffineTransform.identity
                snapshot.alpha = 0
                cell.alpha = 1
            }, completion: { (finished) in
                self.cleanup()
            })

        }
    }
    
    private func customSnapshotFromView(inputView: UIView) -> UIView? {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        if let CurrentContext = UIGraphicsGetCurrentContext() {
            inputView.layer.render(in: CurrentContext)
        }
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0
        snapshot.layer.shadowOffset = CGSize(width: -5, height: 0)
        snapshot.layer.shadowRadius = 5
        snapshot.layer.shadowOpacity = 0.4
        return snapshot
    }
    
    private func cleanup() {
        self.sourceIndexPath = nil
        snapshot?.removeFromSuperview()
        self.snapshot = nil
    }
    
    // MARK: - Delegates

    func addTableView(set: SpinSet) {
        self.sets?.append(set)
        tableView.reloadData()

        let duration = self.sets?.reduce(0) { $0 + $1.seconds }
        totalDurationLabel.text = timeString(interval: duration ?? 0.0, format: "hms")
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
        totalDurationLabel.text = timeString(interval: duration ?? 0.0, format: "hms")
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
            addViewController.gear = selectedSet.gear
            addViewController.cadence = selectedSet.cadence
            addViewController.duration = selectedSet.seconds
            
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
        
        let duration = sets?[indexPath.row].seconds ?? 0.0
        cell.durationLabel.text = timeString(interval: duration, format: "")
        
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
    
}
