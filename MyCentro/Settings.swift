//
//  Settings.swift
//  MyCentro
//
//  Created by Alok Arya on 11/18/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import CoreLocation



//----------Model class used for storing/retrieving App settings data------//

class Settings: NSObject
{
    
    
    override init()
    {
        
    }
    
    //---Home location property-----------------------//
    var HomeLocation: CLLocationCoordinate2D
    {
        
        get
        {            
            //mock data - 607 S Beech Street
            let homeLocationStruct = CLLocationCoordinate2D.init(latitude: 43.043332,longitude: -76.122767);
    
            return homeLocationStruct;
        }
        set(newHomeLocation)
        {
            self.HomeLocation = newHomeLocation;
        }
    }
    
    //------Work or College location property----------//
    var WorkLocation: CLLocationCoordinate2D
    {
        get
        {
            //mock data - Syracuse university College place
            let workLocationStruct = CLLocationCoordinate2D.init(latitude: 43.038572,longitude: -76.134517);
            
            return workLocationStruct;
        }
        set(newWorkLocation)
        {
            self.WorkLocation = newWorkLocation;
        }
    }
    
    //--------Name of the App user-------------//
    var Name = "Alok Arya" ;
    
    
    //--------Clock type: 12 Hour or 24 hour-------//
    var clockType = "24-hour";
    
    
}