//
//  GlobalSplitViewController.swift
//  MyCalculator
//
//  Created by Jonathan L. on 8/8/17.
//  Copyright © 2017 Jonathan L. All rights reserved.
//

import UIKit


//This class sole purpose is to subclass the split view controller so the CalculatorViewController will show by default.
class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
