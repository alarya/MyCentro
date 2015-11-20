//
//  MainScreenController.swift
//  MyCentro
//
//  Created by Alok Arya on 11/16/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import UIKit

class MainScreenController: UIViewController {
    
    @IBOutlet weak var busToHomeButton: UIButton!
    
    @IBOutlet weak var busToWorkButton: UIButton!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //------button Action: Bus To home----------------------------//
    @IBAction func busToHome(sender: UIButton)
    {
        performSegueWithIdentifier("BusListToHome", sender: sender);
    }
    
    //------button Action: Bus to Work/College-------------------//
    @IBAction func busToWork(sender: UIButton)
    {
        performSegueWithIdentifier("BusListToWork", sender: sender);
    }
    
    //-----Segue handler ----------------------------------------//
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "BusListToHome"
        {
            if let destinationVC = segue.destinationViewController as? BusListController
            {
                destinationVC.title = "Bus to Home";
                
                //mock data
                destinationVC.departBusStop = ["College Place", "College Place", "College Place"] ;
                destinationVC.departTime = ["9:30", "10:00", "11:30"];
                destinationVC.busListOf = "BusListToHome";
            }
        }
        else if segue.identifier == "BusListToWork"
        {
            if let destinationVC = segue.destinationViewController as? BusListController
            {
                destinationVC.title = "Bus to Work";
                
                //mock data
                destinationVC.departBusStop =  ["East Genessee & Westcott", "East Genessee & Westcott", "East Genessee & Westcott"] ;
                destinationVC.departTime = ["3:30", "4:00", "5:00"];
                destinationVC.busListOf = "BusListToWork";
            }
        }

    }
}