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

//Reference : http://rebeloper.com/read-write-plist-file-swift/   //

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
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = documentsPath.stringByAppendingString("/Settings.plist");
        
        let fileManager = NSFileManager.defaultManager() ;
        
        //check if file exists
        if !fileManager.fileExistsAtPath(path)
        {
            //if it doesn't , copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("Settings", ofType: "plist")
            {
                //let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                
                //print(resultDictionary?.description)
                
                do
                {
                    try fileManager.copyItemAtPath(bundlePath, toPath: path)
                }
                catch
                {
                    print("Could not copy file..")
                    return ;
                }
                print("file copied to Documents folder from bundle")
            }
            else
            {
                print("Settings.plist not found")
            }
            
        
        }
        else
        {
            //print("Settings.plist already exists")
        }
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        
        let homeLatitude = resultDictionary!.objectForKey("HomeLatitude")
        let homeLongitude = resultDictionary!.objectForKey("HomeLongitude")
        
        self.homeLocation = CLLocationCoordinate2D.init(latitude: (homeLatitude as? CLLocationDegrees)!, longitude: (homeLongitude as? CLLocationDegrees)!)
        
        let workLatitude = resultDictionary!.objectForKey("WorkLatitude")
        let workLongitude = resultDictionary!.objectForKey("WorkLongitude")
        
        self.workLocation = CLLocationCoordinate2D.init(latitude: (workLatitude as? CLLocationDegrees)!, longitude: (workLongitude as? CLLocationDegrees)!)
        
        let homeAddress = resultDictionary!.objectForKey("HomeAddress")
        self.homeAddress = (homeAddress as? String)!
        
        let workAddress = resultDictionary!.objectForKey("WorkAddress")
        self.workAddress = (workAddress as? String)!
        
        /*
        print("Settings")
        print("Home Address")
        print(self.homeAddress)
        print(self.homeLocation.latitude)
        print(self.homeLocation.longitude)
        print("Work Address")
        print(self.workAddress)
        print(self.workLocation.latitude)
        print(self.workLocation.longitude)
        */
   
    }
    
    func saveSettings(homeLocation : CLLocationCoordinate2D, workLocation: CLLocationCoordinate2D, homeAddress: String, workAddress: String)
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory.stringByAppendingString("/Settings.plist")
        
        let dict : NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        
        
        //check if home address was updated 
        if (self.homeAddress != homeAddress){
            dict.setObject(homeLocation.latitude, forKey: "HomeLatitude")
            dict.setObject(homeLocation.longitude, forKey: "HomeLongitude")
            dict.setObject(homeAddress, forKey: "HomeAddress")
        }
        else
        {
            dict.setObject(self.homeLocation.latitude, forKey: "HomeLatitude")
            dict.setObject(self.homeLocation.longitude, forKey: "HomeLongitude")
            dict.setObject(self.homeAddress, forKey: "HomeAddress")
        }
        
        //check if work address was updated
        if (self.workAddress != workAddress)
        {
            dict.setObject(workLocation.latitude, forKey: "WorkLatitude")
            dict.setObject(workLocation.longitude, forKey: "WorkLongitude")
            dict.setObject(workAddress, forKey: "WorkAddress")
        }
        else
        {
            dict.setObject(self.workLocation.latitude, forKey: "WorkLatitude")
            dict.setObject(self.workLocation.longitude, forKey: "WorkLongitude")
            dict.setObject(self.workAddress, forKey: "WorkAddress")
        }
            
        dict.writeToFile(path, atomically: false)
    }
}