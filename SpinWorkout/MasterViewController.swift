//
//  MasterViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UIViewController, NSFetchedResultsControllerDelegate, WorkoutDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addDetailButton: UIBarButtonItem!
    
    //***
    //var workouts: [SpinWorkout]? = []
    //***
    var workouts: [Workout] = []
    var context : NSManagedObjectContext!
    //***
    
    var gradientLayer: CAGradientLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createGradientLayer()
        tableView.backgroundView = nil
        tableView.isOpaque = false
        tableView.backgroundColor = UIColor.clear
        tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)

        // Do any additional setup after loading the view.
        
        //***

//        let set1 = SpinSet(sequence: 1, gear: 3, cadence: 80, seconds: 5.0)
//        let set2 = SpinSet(sequence: 2, gear: 4, cadence: 85, seconds: 5.0)
//        let set3 = SpinSet(sequence: 3, gear: 5, cadence: 90, seconds: 5.0)
//
//        let sets1 = [set1, set2, set3] as? [SpinSet]
//
//        let workout1 = SpinWorkout(title: "Workout 1", sets: sets1)
//
//        let set4 = SpinSet(sequence: 1, gear: 3, cadence: 80, seconds: 5.0)
//        let set5 = SpinSet(sequence: 2, gear: 4, cadence: 85, seconds: 5.0)
//        let set6 = SpinSet(sequence: 3, gear: 5, cadence: 90, seconds: 5.0)
//
//        let sets2 = [set4, set5, set6] as? [SpinSet]
//
//        let workout2 = SpinWorkout(title: "Workout 2", sets: sets2)
//
//        workouts?.append(workout1!)
//        workouts?.append(workout2!)
        //***
        fetchWorkout()
        //***
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        var titleLabel = ""

        if !tableView.isEditing {
            tableView.setEditing(true, animated: true)
            titleLabel = "Done"
        } else {
            tableView.setEditing(false, animated: true)
            titleLabel = "Edit"
        }
        
        sender.title = titleLabel
    }
    
    func createGradientLayer() {
        
        let topColor = UIColor(red: 61.0/255.0, green: 65.0/255.0, blue: 86.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 36.0/255.0, green: 48.0/255.0, blue: 74.0/255.0, alpha: 1.0).cgColor
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [topColor, bottomColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func timeString(interval: TimeInterval) -> String {
        let ti = Int(interval)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return String(format: "%dh %0.2dm %0.2ds", hours, minutes, seconds)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "workout" {
            guard let workoutViewController = segue.destination as? WorkoutViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let workoutCell = sender as? WorkoutTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: workoutCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            //***
            let selectedWorkout = workouts[indexPath.row]
            let workoutTitle = selectedWorkout.title
            var workoutSets: [SpinSet] = []
            
            for workoutSet in selectedWorkout.sets! {
                let ws = workoutSet as! Set
                let spinSet = SpinSet(sequence: Int(ws.sequence), gear: Int(ws.gear), cadence: Int(ws.cadence), seconds: ws.seconds)
                workoutSets.append(spinSet!)
            }

            workoutSets.sort(by: {$0.sequence < $1.sequence})
            
            let spinWorkout = SpinWorkout(title: workoutTitle, sets: workoutSets)
            workoutViewController.workout = spinWorkout

            //***
//            let selectedWorkout = workouts![indexPath.row]
//            workoutViewController.workout = selectedWorkout
            //***

        } else if segue.identifier == "detail" {
            guard let detailViewController = segue.destination as? DetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            if let senderId = sender as? UIBarButtonItem {
                if senderId === addDetailButton {
                    print("add")
                }
            } else {
                print("edit")
                
                guard let workoutCell = sender as? WorkoutTableViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                
                guard let indexPath = tableView.indexPath(for: workoutCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                
                //***
                let selectedWorkout = workouts[indexPath.row]
                let workoutTitle = selectedWorkout.title
                var workoutSets: [SpinSet] = []
                
                for workoutSet in selectedWorkout.sets! {
                    let ws = workoutSet as! Set
                    let spinSet = SpinSet(sequence: Int(ws.sequence), gear: Int(ws.gear), cadence: Int(ws.cadence), seconds: ws.seconds)
                    workoutSets.append(spinSet!)
                }
                
                let spinWorkout = SpinWorkout(title: workoutTitle, sets: workoutSets)
                detailViewController.workout = spinWorkout
                detailViewController.workoutNumber = indexPath.row
                detailViewController.updateMode = true

            }
            
            detailViewController.delegate = self
            
        }

    }
    
    func addTableView(spinWorkout: SpinWorkout) {
        //***
//        workouts?.append(workout)
//        tableView.reloadData()
        
        //***
        let workout = Workout(context: context)

        workout.title = spinWorkout.title

        for set in spinWorkout.sets! {
            let newSet = Set(context: context)
            
            newSet.sequence = Int16(set.sequence)
            newSet.gear = Int16(set.gear)
            newSet.cadence = Int16(set.cadence)
            newSet.seconds = set.seconds
            
            workout.addToSets(newSet)

        }

        try? context.save()
        fetchWorkout()
        //***
    }
    
    func updateTableView(spinWorkout: SpinWorkout, index: Int) {
        if index < 0 || index >= self.workouts.count {
            return
        }
        
        let workout = Workout(context: context)
        
        for workoutSet in workout.sets! {
            let ws = workoutSet as! Set
            workout.removeFromSets(ws)
        }
        
        context.delete(workouts[index])
        
        workouts.remove(at: index)

        workout.title = spinWorkout.title

        for set in spinWorkout.sets! {
            let newSet = Set(context: context)

            newSet.sequence = Int16(set.sequence)
            newSet.gear = Int16(set.gear)
            newSet.cadence = Int16(set.cadence)
            newSet.seconds = set.seconds

            workout.addToSets(newSet)

        }

        try? context.save()
        //tableView.reloadData()
        fetchWorkout()
    }

    // MARK: - Fetched results controller

    func fetchWorkout() {
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        let alphabetSort = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [alphabetSort]
        
        do {
            let workoutArray = try self.context.fetch(fetchRequest)
            self.workouts = workoutArray
            self.tableView.reloadData()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

}

extension MasterViewController: UITableViewDelegate, UITableViewDataSource {

    //MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return workouts!.count
        //***
        return workouts.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as? WorkoutTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UITableViewCell.")
        }
        
        //***
        let workout = workouts[indexPath.row]
        
        var duration = 0.0
        let count = workout.sets?.count ?? 0
        for workoutSet in workout.sets! {
            let ws = workoutSet as! Set
            duration += ws.seconds
        }
        
        cell.workoutTitleLabel.text = workout.title?.uppercased()
        cell.setCountLabel.text = "SETS - \(count)"
        cell.totalDurationLabel.text = timeString(interval: duration)
        
        //***
//        let workout = workouts![indexPath.row]
//
//        let duration = workout.sets?.reduce(0) { $0 + $1.seconds }
//
//        cell.workoutTitleLabel.text = workout.title
//        cell.setCountLabel.text = "\(workout.sets?.count ?? 0)"
//        cell.totalDurationLabel.text = "\(duration ?? 0.0)"
        //***
        
        return cell

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { (UITableViewRowAction, IndexPath) -> Void in
            self.performSegue(withIdentifier: "detail", sender: tableView.cellForRow(at: indexPath))
            
        })
        editAction.backgroundColor = UIColor.blue
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete", handler: { (UITableViewRowAction, IndexPath) -> Void in
            self.context.delete(self.workouts[indexPath.row])
            
            do {
                try self.context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            self.fetchWorkout()

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
            context.delete(workouts[indexPath.row])
 
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            fetchWorkout()
        }

    }

}
