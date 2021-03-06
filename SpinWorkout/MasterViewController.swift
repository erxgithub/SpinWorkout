//
//  MasterViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-08.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UIViewController, NSFetchedResultsControllerDelegate, WorkoutDelegate, HistoryDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addDetailButton: UIBarButtonItem!
    
    //***
    //var workouts: [SpinWorkout]? = []
    //***
    var workouts: [Workout] = []
    var context : NSManagedObjectContext!
    //***
    
    var gradientLayer: CAGradientLayer!
    var navBarLayer: CAGradientLayer!

    fileprivate var sourceIndexPath: IndexPath?
    fileprivate var snapshot: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(longPress:)))
        self.tableView.addGestureRecognizer(longPress)
        
        createGradientLayer()
        createNavBarLayer()
        setupTableView()
        
        navigationController?.navigationBar.tintColor = UIColor.white
      

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
    
    override func viewWillAppear(_ animated: Bool) {
        
        // XCode bug fix where button stays .selected when returning to view
        navigationController?.navigationBar.tintAdjustmentMode = .normal
        navigationController?.navigationBar.tintAdjustmentMode = .automatic
        ///////
    
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
                snapshot.layer.backgroundColor = UIColor(red: 84.0/255.0, green: 89.0/255.0, blue: 115.0/255.0, alpha: 1.0).cgColor
                snapshot.layer.masksToBounds = false
                snapshot.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
                snapshot.layer.shadowRadius = 5.5
                snapshot.layer.shadowOpacity = 0.75
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
                
                workouts.swapAt(indexPath.row, sourceIndexPath.row)
                self.tableView.moveRow(at: sourceIndexPath, to: indexPath)
                self.sourceIndexPath = indexPath
                
                workouts[indexPath.row].sequence = Int16(sourceIndexPath.row)
                workouts[sourceIndexPath.row].sequence = Int16(indexPath.row)

                let maxRow = workouts.count
                for i in 0..<maxRow {
                    workouts[i].sequence = Int16(i) + 1
                }
                
                tableView.reloadData()
                
                try? context.save()
                fetchWorkout()
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

    private func createGradientLayer() {
        
        let topColor = UIColor(red: 57.0/255.0, green: 61.0/255.0, blue: 84.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 49.0/255.0, green: 47.0/255.0, blue: 57.0/255.0, alpha: 1.0).cgColor
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [topColor, bottomColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func createNavBarLayer() {

        let topColor = UIColor(red: 214.0/255.0, green: 150.0/255.0, blue: 56.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 178.0/255.0, green: 127.0/255.0, blue: 43.0/255.0, alpha: 1.0).cgColor

        navBarLayer = CAGradientLayer()
        if let navigationController = navigationController {
            let navFrame = navigationController.navigationBar.frame
            let newFrame = CGRect(origin: .zero, size: CGSize(width: navFrame.width, height: navFrame.height + UIApplication.shared.statusBarFrame.height))
            navBarLayer.frame = newFrame
            navBarLayer.locations = [0.4, 1.0]
            navBarLayer.colors = [topColor, bottomColor]
            navigationController.navigationBar.setBackgroundImage(createGradientImage(layer: navBarLayer), for: .default)
        }
    }
    
    private func createGradientImage(layer: CALayer) -> UIImage {
    
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return outputImage
    }
    
    private func setupTableView() {
        
        let imageView =  UIImageView(image: UIImage(named: "background-screen-table"))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.frame = CGRect(x: 0,
                                       y: tableView.frame.origin.y + (tableView.frame.height / 2),
                                       width: tableView.frame.width,
                                       height: tableView.frame.height / 2)
        
        let tableViewBackgroundView = UIView()
        tableViewBackgroundView.addSubview(imageView)
        tableView.backgroundView = tableViewBackgroundView
        tableView.isOpaque = false
        tableView.backgroundColor = UIColor.clear
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
            workoutViewController.delegate = self
            workoutViewController.workoutNumber = indexPath.row

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

                }
            } else {
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
            
        } else if segue.identifier == "history" {
            guard let graphViewController = segue.destination as? GraphViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            graphViewController.context = context
        }

    }
    
    // MARK: - Delegates

    func addTableView(spinWorkout: SpinWorkout) {
        //***
//        workouts?.append(workout)
//        tableView.reloadData()
        
        //***
        let sequence = Int16(workouts.count + 1)
        
        let workout = Workout(context: context)

        workout.title = spinWorkout.title
        workout.sequence = sequence

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
        
//        let workout = Workout(context: context)
//
//        for workoutSet in workout.sets! {
//            let ws = workoutSet as! Set
//            workout.removeFromSets(ws)
//        }
        
        context.delete(workouts[index])
        
        workouts.remove(at: index)

        let workout = Workout(context: context)
        
        workout.title = spinWorkout.title
        workout.sequence = Int16(index) + 1

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
    }
    
    func addToHistory(index: Int) {
        if index < 0 || index >= self.workouts.count {
            return
        }

        let alertTitle = "Save workout session to history?"
        
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default, handler: { action in
            let workout = self.workouts[index]
            
            let title = workout.title
            
            var totalTime = 0.0
            var totalPower = 0.0
            
            for workoutSet in workout.sets! {
                let ws = workoutSet as! Set
                
                let gear = Double(ws.gear)
                let cadence = Double(ws.cadence)
                let seconds = ws.seconds
                
                let timeValue = (seconds / 60)
                let powerValue = timeValue + (timeValue * pow(gear, 2) * (cadence / 2000))
                
                totalTime += timeValue
                totalPower += powerValue
            }

            let history = History(context: self.context)

            history.date = Date()
            history.title = title
            history.time = totalTime
            history.power = totalPower
            
            try? self.context.save()
        })
        alert.addAction(yes)
        
        let no = UIAlertAction(title: "No", style: .default, handler: { action in

        })
        alert.addAction(no)
        
        self.present(alert, animated: true)
    }

    // MARK: - Fetched results controller

    func fetchWorkout() {
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        let alphabetSort = NSSortDescriptor(key: "sequence", ascending: true)
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
        cell.totalDurationLabel.text = timeString(interval: duration, format: "")
        
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
        editAction.backgroundColor = UIColor(red: 46.0/255.0, green: 46.0/255.0, blue: 88.0/255.0, alpha: 1.0)
        
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
        deleteAction.backgroundColor = UIColor(red: 114.0/255.0, green: 5.0/255.0, blue: 5.0/255.0, alpha: 1.0)

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
