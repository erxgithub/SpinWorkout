//
//  MasterViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var workouts: [Workout]? = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let set1 = Set(number: 1, gear: 3, cadence: 80, seconds: 5.0)
        let set2 = Set(number: 2, gear: 4, cadence: 85, seconds: 5.0)
        let set3 = Set(number: 3, gear: 5, cadence: 90, seconds: 5.0)
        
        let sets1 = [set1, set2, set3] as? [Set]
        
        let workout1 = Workout(title: "Workout 1", sets: sets1)
        
        let set4 = Set(number: 1, gear: 3, cadence: 80, seconds: 5.0)
        let set5 = Set(number: 2, gear: 4, cadence: 85, seconds: 5.0)
        let set6 = Set(number: 3, gear: 5, cadence: 90, seconds: 5.0)
        
        let sets2 = [set4, set5, set6] as? [Set]
        
        let workout2 = Workout(title: "Workout 2", sets: sets2)

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

        }

    }

}

extension MasterViewController: UITableViewDelegate, UITableViewDataSource {

    //MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts!.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as? WorkoutTableViewCell  else {
            fatalError("The dequeued cell is not an instance of UITableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let workout = workouts![indexPath.row]
        
        cell.workoutTitleLabel.text = workout.title
        cell.workoutTitleLabel.sizeToFit()
        
        return cell

    }

}
