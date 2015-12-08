//
//  RoutesListController.swift
//  MyCentro
//
//  Created by Alok Arya on 12/8/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import UIKit


class RoutesListController : UITableViewController
{

    var centroAPI : CentroBusApiCaller ;
    var routeList : [Route];
    
    
    @IBOutlet var routeTableView: UITableView!
    
    
    //--------------Init methods --------------------------------------------//
    convenience init()
    {
        self.init(nibName: nil, bundle: nil);
    }
    //default initializer
    required init(coder aDecoder: NSCoder)
    {
        centroAPI = CentroBusApiCaller();
        routeList = [Route]();
        super.init(coder: aDecoder)!;
    }
    //designated initializer
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        centroAPI = CentroBusApiCaller();
        routeList = [Route]();
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    //--------End of Init methods -------------------------------------------//
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.centroAPI.returnRouteList(self);
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //method called by Centro API Caller to update bus list
    func updateTableView(routeList: [Route])
    {
        
        self.routeList = routeList ;
        
        dispatch_sync(dispatch_get_main_queue(), {
            self.routeTableView.reloadData();
        });
    }
    
    //----------UI Table View delegate methods ----------------------//
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("RouteListCell") as UITableViewCell! ;
        
        cell.textLabel?.text = self.routeList[indexPath.row].rt + " : " +  self.routeList[indexPath.row].rtnm;
        
        return cell;
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.routeList.count ;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        performSegueWithIdentifier("BusDetails", sender: tableView);
    }
    //--------End of UI Table View delegate methods -----------------//
    
    
    //-----Segue handler ----------------------------------------//
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {

    }
    
    //--------------------Utility methods ------------------------------------------------//
    
}