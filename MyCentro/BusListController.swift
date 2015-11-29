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
    var centroAPI : CentroBusApiCaller;
    var busList : [PredictionObject];
    
    @IBOutlet weak var BusListTable: UITableView! ;
    
    @IBOutlet weak var ViewMessage: UILabel!
    
    convenience init()
    {
        self.init(nibName: nil, bundle: nil);
    }
    //default initializer
    required init(coder aDecoder: NSCoder)
    {
        centroAPI = CentroBusApiCaller();
        busList = [PredictionObject]();
        super.init(coder: aDecoder)!;
    }
    //designated initializer
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        centroAPI = CentroBusApiCaller();
        busList = [PredictionObject]();
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //register Custom cells with the table view
        let nib = UINib(nibName: "BusListTableViewCell" , bundle: nil);
        BusListTable.registerNib(nib, forCellReuseIdentifier: "BusListCell");
        
        ViewMessage.hidden = true ;
        
        //------------------
        if(busListOf != nil)
        {
            if(busListOf == "BusListToHome")
            {
                let source = CLLocation.init(latitude: 43.043317, longitude: -76.151389);
                let destination = CLLocation.init(latitude: 43.076548, longitude: -76.169244);

                centroAPI.getListOfBuses(source, destination: destination, controller : self);
         
            }
            else if(busListOf == "BusListToWork")
            {
                let source = CLLocation.init(latitude: 43.043317, longitude: -76.151389);    //SU
                let destination = CLLocation.init(latitude: 43.076548, longitude: -76.169244);  //Irving Ave Harrison St
                
                centroAPI.getListOfBuses(source, destination: destination, controller : self);
            }
            else if(busListOf == "CustomRouteBuses")
            {
                
            }
        }
        else
        {
            //error - Handling
            
            //could not find any list of Buses
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTableView(predictionList: [PredictionObject])
    {
        for prediction in predictionList
        {
            self.busList.append(prediction);
        }

        dispatch_sync(dispatch_get_main_queue(), {
            self.BusListTable.reloadData();
        });
    }
    
    //----------UI Table View delegate methods ----------------------//
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BusListCell") as! BusListTableViewCell ;
        
        let route = self.busList[indexPath.row].rt + ": " + self.busList[indexPath.row].rtnm;
        let src = self.busList[indexPath.row].sourcestpnm;
        let dest = self.busList[indexPath.row].deststpnm;
        let srctm = self.busList[indexPath.row].sourceprdtm.componentsSeparatedByString(" ").last ;
        let desttm = self.busList[indexPath.row].destprdtm.componentsSeparatedByString(" ").last ;
        
        print(self.busList);
        // test
        //cell.loadCell("Westcott", sourceName: "destinty", sourceTime: "15:00", destName: "College Place", destTime: "15:30") ;
        
        cell.loadCell(route, sourceName: src, sourceTime: srctm!, destName: dest, destTime: desttm!) ;
        
        return cell;
        
    }
 
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if self.busList.count == 0
        {
            ViewMessage.hidden = false;
            BusListTable.hidden = true;
            ViewMessage.text = "No Services on this route currently ..." ;
        }
        else
        {
            ViewMessage.hidden = true;
            ViewMessage.text = "" ;
            BusListTable.hidden = false;
            return self.busList.count;
        }
        
        return 0;
    }
    //--------End of UI Table View delegate methods -----------------//
    
    
    //-----Segue handler ----------------------------------------//
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "BusDetails"
        {
            //let selectedCellIndex = BusListTable.indexPathForSelectedRow ;
            //let trip = BusListTable.cellForRowAtIndexPath(selectedCellIndex!) ;
   
            let destController = segue.destinationViewController as? BusDetailsController;
            let busDetails = BusDetails();
            busDetails.sourceName = "Source";
            busDetails.sourceTime = "15:00";
            busDetails.destName = "Destination";
            busDetails.destTime = "15:30";
            destController!.busDetails = busDetails;
        }
    }
}

class BusListTableViewCell : UITableViewCell
{
    @IBOutlet weak var route : UILabel!;
    @IBOutlet weak var sourceName : UILabel!;
    @IBOutlet weak var sourceTime : UILabel!;
    @IBOutlet weak var destName : UILabel!;
    @IBOutlet weak var destTime : UILabel!;
    
    func loadCell(route: String, sourceName: String, sourceTime: String, destName: String, destTime: String)
    {
        self.route.text = route;
        self.sourceName.text = sourceName;
        self.sourceTime.text = sourceTime;
        self.destName.text = destName;
        self.destTime.text = destTime;
    }
}
