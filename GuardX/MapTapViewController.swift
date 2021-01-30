//
//  MapTapViewController.swift
//  GuardX
//
//  Created by Ezer Patlan on 12/24/18.
//  Copyright © 2018 Ezer Patlan. All rights reserved.
//

import UIKit

class MapTapViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    //var mapTabView: UIView!
    //var directionTabView: UIView!
    //var views: [UIView]!
    
    
    lazy var MapChildTapViewController: MapChildTapViewController = { var viewController = self.storyboard?.instantiateViewController(withIdentifier: "MapChildTapViewController") as! MapChildTapViewController
        self.addChildVC(childViewController: viewController)
        return viewController
    }()
    
    lazy var LocationChildViewController: LocationChildViewController = { var viewController = self.storyboard?.instantiateViewController(withIdentifier: "LocationChildViewController") as! LocationChildViewController
        self.addChildVC(childViewController: viewController)
        return viewController
        
    }()
    
    
    func addChildVC(childViewController: UIViewController) {
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.view.frame = view.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childViewController.didMove(toParent: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        segmentControl.selectedSegmentIndex = 0
        updateChildVC()
        
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateChildVC() {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            MapChildTapViewController.view.isHidden = false
            LocationChildViewController.view.isHidden = true
        case 1:
            MapChildTapViewController.view.isHidden = true
            LocationChildViewController.view.isHidden = false
        default:
            return
        }
    }
    
    
    @IBAction func switchViewAction(_ sender: UISegmentedControl) {
        updateChildVC()
}


/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */

}
