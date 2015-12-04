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
    var homeLocation = CLLocationCoordinate2D.init()
    
    var workLocation = CLLocationCoordinate2D.init()
    
    var homeAddress = "" ;
    
    var workAddress = "" ;
    
    //var Name = "Alok Arya" ;
    
    //var clockType = "24-hour";
    
    override init()
    {
        super.init();
        self.loadSettings();
    }
 
    
    func loadSettings()
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory + "/" + "Settings.plist"
        //let path = documentsDirectory.URLByAppendingPathComponent("Settings.plist");
        
        let fileManager = NSFileManager.defaultManager() ;
        
        if !fileManager.fileExistsAtPath(path)
        {
            if let bundlePath = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")
            {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                print(resultDictionary?.description)
                do
                {
                    try fileManager.copyItemAtPath(bundlePath, toPath: path)
                }
                catch
                {
                    return ;
                }
                print("copy")
            }
            else
            {
                print("Settings.plist not found")
            }
            
            
        }
        else
        {
            print("Settings.plist already exists")
        }
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        print(resultDictionary?.description)
        let myDict = NSDictionary(contentsOfFile: path)
        if let dict = myDict
        {
            let homeLatitude = dict.objectForKey("HomeLatitude");
            let homeLongitude = dict.objectForKey("HomeLongitude");
            
            self.homeLocation = CLLocationCoordinate2D.init(latitude: (homeLatitude as? CLLocationDegrees)!, longitude: (homeLongitude as? CLLocationDegrees)!);
            
            let workLatitude = dict.objectForKey("WorkLatitude");
            let workLongitude = dict.objectForKey("WorkLongitude");
            
            self.workLocation = CLLocationCoordinate2D.init(latitude: (workLatitude as? CLLocationDegrees)!, longitude: (workLongitude as? CLLocationDegrees)!);
            
            let homeAddress = dict.objectForKey("HomeAddress");
            self.homeAddress = (homeAddress as? String)! ;
            
            let workAddress = dict.objectForKey("WorkAddress");
            self.workAddress = (workAddress as? String)! ;
        }
   
    }
    
    func saveSettings(homeLocation : CLLocationCoordinate2D, workLocation: CLLocationCoordinate2D, homeAddress: String, workAddress: String)
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentationDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory + "/" + "Settings.plist"
        
        let dict: NSMutableDictionary = ["":""]
        
        dict.setObject(homeLocation.latitude, forKey: "HomeLatitude")
        dict.setObject(homeLocation.longitude, forKey: "HomeLongitude")
        dict.setObject(workLocation.latitude, forKey: "WorkLatitude")
        dict.setObject(workLocation.longitude, forKey: "WorkLongitude")
        dict.setObject(homeAddress, forKey: "HomeAddress")
        dict.setObject(workAddress, forKey: "WorkAddress")
        
        dict.writeToFile(path, atomically: false)
        
        self.homeLocation = homeLocation
        self.workLocation = workLocation
        self.homeAddress = homeAddress
        self.workAddress = homeAddress
    }
}