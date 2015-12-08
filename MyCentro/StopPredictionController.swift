//
//  StopPredictionController.swift
//  MyCentro
//
//  Created by Alok Arya on 12/8/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import UIKit


class StopPredictionController : UIViewController
{
    var centroAPI : CentroBusApiCaller ;
    var stop = Stop();
    var direction = "";
    var route = Route() ;
    var stopPrediction = Prediction();
    
    @IBOutlet weak var routeLabel: UILabel!
    
    @IBOutlet weak var directionLabel: UILabel!
    
    @IBOutlet weak var stopLabel: UILabel!
    
    @IBOutlet weak var arrivalLabel: UILabel!
    
    //--------------Init methods --------------------------------------------//
    convenience init()
    {
        self.init(nibName: nil, bundle: nil);
    }
    //default initializer
    required init(coder aDecoder: NSCoder)
    {
        self.centroAPI = CentroBusApiCaller();
        super.init(coder: aDecoder)!;
    }
    //designated initializer
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        self.centroAPI = CentroBusApiCaller();
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    //--------End of Init methods -------------------------------------------//
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.centroAPI.returnStopPrediction(self.stop.stpid, route: self.route.rt, dir: self.direction,controller: self);
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //method called by Centro API Caller to update bus list
    func updateView(stopPrediction: Prediction)
    {
        
        self.stopPrediction = stopPrediction ;
        
        dispatch_sync(dispatch_get_main_queue(), {
            
            self.routeLabel.text = self.route.rt + " : " + self.route.rtnm ;
            
            self.directionLabel.text = self.direction ;
            
            self.stopLabel.text = self.stop.stpnm ;
            
            self.arrivalLabel.text = self.stopPrediction.prdtm.componentsSeparatedByString(" ").last ;
        });
    }
    

    
    //--------------------Utility methods ------------------------------------------------//
    
}