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
    var busDetails: BusDetails ;
    
    convenience init()
    {
        self.init(nibName: nil, bundle: nil);
    }
    //default initializer
    required init(coder aDecoder: NSCoder)
    {
        self.busDetails = BusDetails();
        super.init(coder: aDecoder)!;
    }
    //designated initializer
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        self.busDetails = BusDetails();
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}