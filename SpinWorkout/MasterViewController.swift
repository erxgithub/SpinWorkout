//
//  MasterViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UIViewController, WorkoutDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var workouts: [SpinWorkout]? = []
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
            
            let selectedWorkout = workouts![indexPath.row]
            workoutViewController.workout = selectedWorkout

        } else if segue.identifier == "detail" {
            guard let detailViewController = segue.destination as? DetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            detailViewController.delegate = self

        }

    }
    
    func updateTableView(workout: SpinWorkout) {
        workouts?.append(workout)
        tableView.reloadData()
    }

}

extension MasterViewController: UITableViewDelegate, UITableViewDataSource {

    //MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts!.count
        //return people.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as? WorkoutTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UITableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let workout = workouts![indexPath.row]
        //let person = people[indexPath.row]
        
        let duration = workout.sets?.reduce(0) { $0 + $1.seconds }
        
        cell.workoutTitleLabel.text = workout.title
        cell.setCountLabel.text = "\(workout.sets?.count ?? 0)"
        cell.totalDurationLabel.text = "\(duration ?? 0.0)"
        
        //cell.workoutTitleLabel.text = person.value(forKeyPath: "title") as? String
        //cell.workoutTitleLabel.sizeToFit()
        
        return cell

    }

}
