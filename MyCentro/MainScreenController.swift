//
//  MainScreenController.swift
//  MyCentro
//
//  Created by Alok Arya on 11/16/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class MainScreenController: UIViewController, CLLocationManagerDelegate
{
    
    @IBOutlet weak var busToHomeButton: UIButton!
    
    @IBOutlet weak var busToWorkButton: UIButton!
    
    var locationManager = CLLocationManager();
    
    var currentLocation = CLLocation.init(latitude: 0.0, longitude: 0.0);
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.locationManager.delegate = self ;
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation();
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
                
                destinationVC.busListOf = "BusListToHome";
                
                destinationVC.currentLocation = CLLocationCoordinate2D.init(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude)
            }
        }
        else if segue.identifier == "BusListToWork"
        {
            if let destinationVC = segue.destinationViewController as? BusListController
            {
                destinationVC.title = "Bus to Work";
                
                destinationVC.busListOf = "BusListToWork";
                
                destinationVC.currentLocation = CLLocationCoordinate2D.init(latitude: self.currentLocation.coordinate.latitude, longitude: self.currentLocation.coordinate.longitude)
            }
        }
        else if segue.identifier == "Settings"
        {
           if let destinationVC = segue.destinationViewController as? SettingsController
           {
                destinationVC.title = "Settings" ;
           }
        }
        else if segue.identifier == "SearchBuses"
        {
            if let destinationVC = segue.destinationViewController as? SearchBusesController
            {
                destinationVC.title = "Search Buses" ;
            }
        }
        else if segue.identifier == "RouteList"
        {
            if let destinationVC = segue.destinationViewController as? RoutesListController
            {
                destinationVC.title = "Routes" ;
            }
        }
    }
    
    //------------CLLocationManager delegate methods -------------------------------//
    
    //update current location if available
    func locationManager(manager: CLLocationManager,didUpdateLocations locations: [CLLocation])
    {
        self.currentLocation = locations.last! ;
    }
    
    //----------End of CLLocationManager delegate methods ----------------------------//
}