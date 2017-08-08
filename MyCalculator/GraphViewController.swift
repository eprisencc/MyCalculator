//
//  ViewController.swift
//  GraphingFunctions
//
//  Created by Jonathan L. on 8/3/17.
//  Copyright © 2017 Jonathan L. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.myData = DataSource(function: functionToGraph)
            let panHandler = #selector(GraphView.moveOrigin(byReactingTo:))
            let panRecognizer = UIPanGestureRecognizer(target: graphView, action: panHandler)
            graphView.addGestureRecognizer(panRecognizer)
            
            let pinchHandler = #selector(GraphView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: graphView, action: pinchHandler)
            graphView.addGestureRecognizer(pinchRecognizer)
            
            let tapHandler = #selector(GraphView.doubleTap(byReactingTo:))
            let tapRecognizer = UITapGestureRecognizer(target: graphView, action: tapHandler)
            tapRecognizer.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    var functionToGraph: ((CGFloat) -> Double)? {
        didSet {
            graphView?.myData = DataSource(function: functionToGraph)
        }
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}

