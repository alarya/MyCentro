//
//  DirectionsListController.swift
//  MyCentro
//
//  Created by Alok Arya on 12/8/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import UIKit


class DirectionsListController : UITableViewController
{
    
    var route : Route;
    var directions : [String];
    var centroAPI : CentroBusApiCaller ;
    
    
    @IBOutlet var directionTableView: UITableView!
   
    
    
    //--------------Init methods --------------------------------------------//
    convenience init()
    {
        self.init(nibName: nil, bundle: nil);
        self.directions = [String]() ;
    }
    //default initializer
    required init(coder aDecoder: NSCoder)
    {
        self.route = Route() ;
        self.directions = [String]() ;
        centroAPI = CentroBusApiCaller();
        super.init(coder: aDecoder)!;
        
    }
    //designated initializer
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        self.directions = [String]() ;
        self.route = Route() ;
        centroAPI = CentroBusApiCaller();
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        
    }
    //--------End of Init methods -------------------------------------------//
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.centroAPI.returnDirectionList(self.route.rt, controller: self);
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //method called by Centro API Caller to update bus list
    func updateTableView(directionList: [String])
    {
        
        self.directions = directionList ;
        
        dispatch_sync(dispatch_get_main_queue(), {
            self.directionTableView.reloadData();
        });
    }
    
    //----------UI Table View delegate methods ----------------------//
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DirectionListCell") as UITableViewCell! ;
        
        cell.textLabel?.text = self.directions[indexPath.row];
        return cell;
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.directions.count ;
    }

    //--------End of UI Table View delegate methods -----------------//
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let destinationVC = segue.destinationViewController as? StopsListController
        {
            destinationVC.title = "Stops" ;
            destinationVC.route = route ;
            destinationVC.direction = self.directions[(self.directionTableView.indexPathForSelectedRow?.row)!];
        }
    }
    
    //--------------------Utility methods ------------------------------------------------//
    

}