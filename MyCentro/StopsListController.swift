//
//  StopsListController.swift
//  MyCentro
//
//  Created by Alok Arya on 12/8/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import UIKit


class StopsListController : UITableViewController
{
    var centroAPI : CentroBusApiCaller ;
    var stopList : [Stop];
    var direction = "";
    var route = Route() ;
    
    @IBOutlet var stopTableView: UITableView!
    
    //--------------Init methods --------------------------------------------//
    convenience init()
    {
        self.init(nibName: nil, bundle: nil);
    }
    //default initializer
    required init(coder aDecoder: NSCoder)
    {
        self.centroAPI = CentroBusApiCaller();
        self.stopList = [Stop]();
        super.init(coder: aDecoder)!;
    }
    //designated initializer
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        self.centroAPI = CentroBusApiCaller();
        self.stopList = [Stop]();
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    //--------End of Init methods -------------------------------------------//
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.centroAPI.returnStopList(self.route.rt,direction: self.direction,controller: self);
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //method called by Centro API Caller to update bus list
    func updateTableView(stopList: [Stop])
    {
        
        self.stopList = stopList ;
        
        dispatch_sync(dispatch_get_main_queue(), {
            self.stopTableView.reloadData();
        });
    }
    
    //----------UI Table View delegate methods ----------------------//
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StopListCell") as UITableViewCell! ;
        
        cell.textLabel?.text = self.stopList[indexPath.row].stpnm ;
        
        return cell;
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.stopList.count ;
    }
    
    //override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    //{
    //    performSegueWithIdentifier("DirectionList", sender: indexPath.row) ;
    //}
    //--------End of UI Table View delegate methods -----------------//
    
    
    //-----Segue handler ----------------------------------------//
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if let destinationVC = segue.destinationViewController as? StopPredictionController
        {
            destinationVC.title = "Stop Prediction" ;
            
            destinationVC.route = self.route ;
            
            destinationVC.direction = self.direction ;
            
            destinationVC.stop = self.stopList[(self.stopTableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    //--------------------Utility methods ------------------------------------------------//

}