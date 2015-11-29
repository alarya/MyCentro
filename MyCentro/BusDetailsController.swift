//
//  BusDetailsController.swift
//  MyCentro
//
//  Created by Alok Arya on 11/17/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class BusDetailsController: UIViewController
{
    var busDetails: PredictionObject ;
    @IBOutlet weak var sourceName: UILabel!
    @IBOutlet weak var destName: UILabel!
    @IBOutlet weak var sourceTime: UILabel!
    @IBOutlet weak var destTime: UILabel!
    
    convenience init()
    {
        self.init(nibName: nil, bundle: nil);
    }
    //default initializer
    required init(coder aDecoder: NSCoder)
    {
        self.busDetails = PredictionObject();
        super.init(coder: aDecoder)!;
    }
    //designated initializer
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        self.busDetails = PredictionObject();
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.sourceName.text = self.busDetails.sourcestpnm ;
        self.destName.text = self.busDetails.deststpnm ;
        self.sourceTime.text = self.busDetails.sourceprdtm.componentsSeparatedByString(" ").last ;
        self.destTime.text = self.busDetails.destprdtm.componentsSeparatedByString(" ").last ; 
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}