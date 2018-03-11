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
    
    //***
    var workouts: [SpinWorkout]? = []
    //var workouts: [NSManagedObject] = []
    var managedObjectContext: NSManagedObjectContext? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //***
        let set1 = SpinSet(sequence: 1, gear: 3, cadence: 80, seconds: 5.0)
        let set2 = SpinSet(sequence: 2, gear: 4, cadence: 85, seconds: 5.0)
        let set3 = SpinSet(sequence: 3, gear: 5, cadence: 90, seconds: 5.0)

        let sets1 = [set1, set2, set3] as? [SpinSet]

        let workout1 = SpinWorkout(title: "Workout 1", sets: sets1)

        let set4 = SpinSet(sequence: 1, gear: 3, cadence: 80, seconds: 5.0)
        let set5 = SpinSet(sequence: 2, gear: 4, cadence: 85, seconds: 5.0)
        let set6 = SpinSet(sequence: 3, gear: 5, cadence: 90, seconds: 5.0)

        let sets2 = [set4, set5, set6] as? [SpinSet]

        let workout2 = SpinWorkout(title: "Workout 2", sets: sets2)

        workouts?.append(workout1!)
        workouts?.append(workout2!)
        //***

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "workout" {
            //let controller = segue.destination as! WorkoutViewController
            //controller.delegate = self
            
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
            let selectedWorkout = workouts![indexPath.row]
            workoutViewController.workout = selectedWorkout
            //***

        } else if segue.identifier == "detail" {
            guard let detailViewController = segue.destination as? DetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            detailViewController.delegate = self

        }

    }
    
    func updateTableView(workout: SpinWorkout) {
        //***
        workouts?.append(workout)
        tableView.reloadData()
        
        //***
//        let context = self.fetchedResultsController.managedObjectContext
//        let newWorkout = Workout(context: context)
//
//        newWorkout.title = workout.title
//
//        for set in workout.sets! {
//            let newSet = Set(context: context)
//            newSet.sequence = Int16(set.sequence)
//            newSet.gear = Int16(set.gear)
//            newSet.cadence = Int16(set.cadence)
//            newSet.seconds = set.seconds
//
//        }
//        //newWorkout.sets = workout.sets
//
//        // Save the context.
//        do {
//            try context.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }

    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Workout> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Workout>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)! as! WorkoutTableViewCell, withEvent: anObject as! Workout)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)! as! WorkoutTableViewCell, withEvent: anObject as! Workout)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
     // In the simplest, most efficient, case, reload the table view.
     tableView.reloadData()
     }
     */

}

extension MasterViewController: UITableViewDelegate, UITableViewDataSource {

    //MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts!.count
        //***
        //return workouts.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as? WorkoutTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UITableViewCell.")
        }
        
        //***
        //let workout = workouts[indexPath.row]
        let workout = workouts![indexPath.row]

        let duration = workout.sets?.reduce(0) { $0 + $1.seconds }

        cell.workoutTitleLabel.text = workout.title
        cell.setCountLabel.text = "\(workout.sets?.count ?? 0)"
        cell.totalDurationLabel.text = "\(duration ?? 0.0)"

        // Fetches the appropriate meal for the data source layout.
        //***
//        let event = fetchedResultsController.object(at: indexPath)
//        configureCell(cell, withEvent: event)

        return cell

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //***
//            let context = fetchedResultsController.managedObjectContext
//            context.delete(fetchedResultsController.object(at: indexPath))
//
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
        }
    }

    //***
    func configureCell(_ cell: WorkoutTableViewCell, withEvent workout: Workout) {
        //let duration = workout.sets?.reduce(0) { $0 + $1.seconds }
        let duration = 0.0
        let setsCount = 0

        cell.workoutTitleLabel.text = workout.title
        cell.setCountLabel.text = "\(setsCount)"
        cell.totalDurationLabel.text = "\(duration)"
    }

}
