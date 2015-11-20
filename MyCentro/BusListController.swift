//
//  ViewController.swift
//  MyCentro
//
//  Created by Alok Arya on 11/16/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import UIKit
import CoreLocation

class BusListController: UIViewController,UITableViewDataSource {

    var departBusStop = [String]();
    var departTime = [String]();
    var sourceLocation: CLLocationCoordinate2D?;
    var destinationLocation: CLLocationCoordinate2D? ;
    var busListOf: String?;
    
    //default initializer
    //required init(coder aDecoder: NSCoder)
    //{
    //super.init(coder: aDecoder)!;
    //}
    
    //designated initializer
    //override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    //{
        
    //    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    //}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if(busListOf != nil)
        {
            if(busListOf == "BusListToHome")
            {
                
            }
            else if(busListOf == "BusListToWork")
            {
                
            }
        }
        else
        {
            //error - Handling
            
            //could not find any list of Buses
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BusListCell", forIndexPath: indexPath);
        
        let busStop = departBusStop[indexPath.row];
        let busDepartTime = departTime[indexPath.row];
        
        cell.textLabel?.text = busStop;
        cell.detailTextLabel?.text = busDepartTime;
        
        return cell;
        
    }
 
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int
    {
        return departBusStop.count;
    }
    
    //-----Segue handler ----------------------------------------//
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        
    }
}

