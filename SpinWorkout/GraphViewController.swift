//
//  GraphViewController.swift
//  
//
//  Created by Eric Gregor on 2018-03-16.
//

import UIKit
import ScrollableGraphView

class GraphViewController: UIViewController, ScrollableGraphViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        return 0.0
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return ""
    }
    
    func numberOfPoints() -> Int {
        return 0
    }
    
}
