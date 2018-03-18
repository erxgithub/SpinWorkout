//
//  GraphViewController.swift
//  SpinWorkout
//
//  Created by Eric Gregor on 2018-03-16.
//  Copyright © 2018 Eric Gregor. All rights reserved.
//

import UIKit
import ScrollableGraphView
import CoreData

class GraphViewController: UIViewController, ScrollableGraphViewDataSource {

    @IBOutlet weak var graphSubview: UIView!
    @IBOutlet weak var legendView: UIView!
    @IBOutlet weak var powerView: UIView!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var numberOfDataItems = 30
    
    var graphView: ScrollableGraphView!
    var graphConstraints = [NSLayoutConstraint]()
    
    lazy var timeBarData: [Double] = []
    lazy var powerBarData: [Double] = []
    lazy var xAxisLabelData: [Date] = []
    
    var history: [History] = []
    var context : NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        fetchHistory()
        
        if history.count == 0 {
            generateSampleData()
        }
        //print(history.count)

        graphView = createBarGraph(self.view.frame)
        graphSubview.addSubview(graphView)
        setupConstraints()
        addLegend()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // min 0, max 100
    private func createBarGraph(_ frame: CGRect) -> ScrollableGraphView {
        
        let graphView = ScrollableGraphView(frame: frame, dataSource: self)
        
        // setup the bar plots
        
        let timeBarPlot = BarPlot(identifier: "powerBar")
        
        timeBarPlot.barWidth = 25
        timeBarPlot.barLineWidth = 1
        timeBarPlot.barLineColor = UIColor(hexString: "#777777")!
        timeBarPlot.barColor = UIColor(hexString: "#ff7d78")!
        
        timeBarPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        timeBarPlot.animationDuration = 1.5
        
        let powerBarPlot = BarPlot(identifier: "timeBar")
        
        powerBarPlot.barWidth = 25
        powerBarPlot.barLineWidth = 1
        powerBarPlot.barLineColor = UIColor(hexString: "#777777")!
        powerBarPlot.barColor = UIColor(hexString: "#16aafc")!
        
        powerBarPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        powerBarPlot.animationDuration = 1.5
        
        // setup the reference lines
        
        let referenceLines = ReferenceLines()
        
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.white
        
        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
        
        // setup the graph
        
        graphView.backgroundFillColor = UIColor(hexString: "#333333")!
        graphView.shouldAnimateOnStartup = true
        
        graphView.rangeMax = 100
        graphView.rangeMin = 0
        
        graphView.addPlot(plot: timeBarPlot)
        graphView.addPlot(plot: powerBarPlot)
        graphView.addReferenceLines(referenceLines: referenceLines)
        
        return graphView
    }
    
    private func setupConstraints() {
        
        self.graphView.translatesAutoresizingMaskIntoConstraints = false
        graphConstraints.removeAll()
        
        let topConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        
        graphConstraints.append(topConstraint)
        graphConstraints.append(bottomConstraint)
        graphConstraints.append(leftConstraint)
        graphConstraints.append(rightConstraint)
        
        self.view.addConstraints(graphConstraints)
    }
    
    func addLegend() {
        legendView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        timeView.backgroundColor = UIColor(hexString: "#16aafc")
        timeLabel.textColor = UIColor.white
        powerView.backgroundColor = UIColor(hexString: "#ff7d78")
        powerLabel.textColor = UIColor.white
        
        graphSubview.bringSubview(toFront: legendView)
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        // return the data for each plot
        
        switch(plot.identifier) {
        case "timeBar":
            return history[pointIndex].seconds / 2
            //return timeBarData[pointIndex] / 2
        case "powerBar":
            return (history[pointIndex].power +
                history[pointIndex].seconds) / 2
//            return (powerBarData[pointIndex] + timeBarData[pointIndex]) / 2
        default:
            return 0
        }
    }
    
    func label(atIndex pointIndex: Int) -> String {
        var xAxisLabel = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        let dateValue = history[pointIndex].date
//        let dateValue = xAxisLabelData[pointIndex]
        let day = Calendar.current.component(.day, from: dateValue!)
        
        if day == 1 || pointIndex == 0 {
            xAxisLabel = formatter.string(from: dateValue!) + " \(day)"
        } else {
            xAxisLabel = "\(day)"
        }
        
        return xAxisLabel
    }
    
    func numberOfPoints() -> Int {
        return numberOfDataItems
    }
    
    // sample data generation
    
    private func generateSampleData() {
        let max: UInt32 = 90
        let min: UInt32 = 30
        
        let startDate = Calendar.current.date(byAdding: .day, value: (numberOfDataItems - 1) * -1, to: Date())

//        var index = history.count - 1
//
//        while index >= 0 {
//            context.delete(history[index])
//            history.remove(at: index)
//            index -= 1
//        }

        //print(history.count)
        for i in 0 ..< numberOfDataItems {
            let timeNumber = Double(arc4random_uniform(max - min + 1) + min)
            timeBarData.append(timeNumber)
            
            let powerNumber = Double(arc4random_uniform(max - min + 1) + min)
            powerBarData.append(powerNumber)
            
            let dateValue = Calendar.current.date(byAdding: .day, value: i, to: startDate!)
            xAxisLabelData.append(dateValue!)

            let workout = History(context: context)
            
            workout.date = dateValue
            workout.title = "Demo Workout"
            workout.seconds = timeNumber
            workout.power = powerNumber
            
            history.append(workout)
            try? context.save()
        }

        fetchHistory()
        //print(history.count)

        //graphView.reload()

        return
    }

    // MARK: - Fetched results controller
    
    func fetchHistory() {
        let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
        let dateSort = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [dateSort]
        
        do {
            let historyArray = try self.context.fetch(fetchRequest)
            self.history = historyArray
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            var hexValue = hexString
            
            if hexValue.count == 7 {
                hexValue += "ff"
            }
            
            let start = hexValue.index(hexValue.startIndex, offsetBy: 1)
            let hexColor = String(hexValue[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
