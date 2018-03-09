//
//  DetailViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit

protocol WorkoutDelegate {
    func updateTableView(sets: [SpinSet])
}

class DetailViewController: UIViewController, SetDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var workout: SpinWorkout?
    var sets: [SpinSet]? = []

    var delegate : WorkoutDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    func updateTableView(set: SpinSet) {
        sets?.append(set)
        tableView.reloadData()
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
        
        // Fetches the appropriate meal for the data source layout.
        //let workoutSet = sets![indexPath.row]
        
        //cell.workoutTitleLabel.text = workout.title
        //cell.workoutTitleLabel.sizeToFit()
        
        return cell
        
    }
    
}
