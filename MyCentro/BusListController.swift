//
//  ViewController.swift
//  MyCentro
//
//  Created by Alok Arya on 11/16/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import UIKit
import CoreLocation


class BusListController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    var departBusStop = [String]();
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
        
        //mock data for test
        let mock1 = PredictionObject() ;
        mock1.sourcelocation = CLLocation.init(latitude: 43.012135659673, longitude: -76.11685395240801);
        mock1.destlocation = CLLocation.init(latitude: 43.016497338119, longitude: -76.11913383006998) ;
        mock1.sourcestpnm = "621 SKYTOP RD" ;
        mock1.deststpnm = "GOLDSTEIN STUDENT CENTER" ;
        mock1.sourceprdtm = "15:00";
        mock1.destprdtm = "16:00";
        mock1.rtnm = "South Campus" ;
        mock1.sourcestpid = "17481";
        mock1.deststpid = "17368";
        mock1.rtdir = "FROM CAMPUS";
        mock1.rt = "344" ;
        self.busList.append(mock1);
        
        let mock2 = PredictionObject();
        mock2.sourcelocation = CLLocation.init(latitude: 43.037258730599916, longitude: -76.13144158691938);
        mock2.destlocation = CLLocation.init(latitude: 43.035877956259, longitude: -76.13923430442799) ;
        mock2.sourcestpnm = "COLLEGE PLACE" ;
        mock2.deststpnm = "E RAYNOR AVE + STADIUM PL" ;
        mock2.sourceprdtm = "15:30";
        mock2.destprdtm = "16:30";
        mock2.rtnm = "Connective Corridor" ;
        mock2.sourcestpid = "1683";
        mock2.deststpid = "1675";
        mock2.rtdir = "FROM CAMPUS";
        mock2.rt = "443" ;
        self.busList.append(mock2);
        //-----------------------
        
        BusListTable.delegate = self ;
        
        ViewMessage.hidden = true ;
        
        //------------------
        if(busListOf != nil)
        {
            if(busListOf == "BusListToHome")
            {
                //let source = CLLocation.init(latitude: 43.043317, longitude: -76.151389);
                //let destination = CLLocation.init(latitude: 43.076548, longitude: -76.169244);

                //centroAPI.getListOfBuses(source, destination: destination, controller : self);
         
            }
            else if(busListOf == "BusListToWork")
            {
                //let source = CLLocation.init(latitude: 43.038572, longitude: -76.134517 );    //SU
                //let destination = CLLocation.init(latitude: 43.049577, longitude: -76.150281);  //Irving Ave Harrison St
                
                //centroAPI.getListOfBuses(source, destination: destination, controller : self);
            }
            else if(busListOf == "CustomRouteBuses")
            {
                let source = CLLocation.init(latitude: (self.sourceLocation?.latitude)!, longitude: (self.sourceLocation?.longitude)!);
                let destination = CLLocation.init(latitude: (self.destinationLocation?.latitude)!, longitude: (self.destinationLocation?.longitude)!);
                
                centroAPI.getListOfBuses(source, destination: destination, controller : self);
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        performSegueWithIdentifier("BusDetails", sender: tableView);
    }
    //--------End of UI Table View delegate methods -----------------//
    
    
    //-----Segue handler ----------------------------------------//
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "BusDetails"
        {
            let destController = segue.destinationViewController as? BusDetailsController;
            let tableview = sender as? UITableView ;
            let busDetails = self.busList[(tableview?.indexPathForSelectedRow?.row)!];
            destController!.busDetails = busDetails;
            destController!.title = "Bus Details" ;
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
