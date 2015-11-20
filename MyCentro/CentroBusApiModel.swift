//
//  CentroBusApiModel.swift
//  MyCentro
//
//  Created by Alok Arya on 11/18/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation

//------Interacts with Centro API to get data on buses

class CentroBusApiModel : BusModelProtocol{
    
    let developerKey = "Pq4DwizSLTiwePeFD5cqXyYbt";     //change this value to update developer key used
    let baseURI = "http://bus-time.centro.org/bustime/api/v1";       //change this to update base URI and version of centro API
    var action = "" ;
    var arguments = [String : String]() ;
    
    var request : String
    {
        get
        {
            var argumentsStringified : String ;
            for(key, value) in self.arguments{
                argumentsStringified += "&" ;
                argumentsStringified += key;
                argumentsStringified += "=" ;
                argumentsStringified += value ;
                
            }
            
            return baseURI + "/" + self.action + "?" + "key" + "=" + self.developerKey + argumentsStringified ;
            
            /* Sample string 
             *
             *   http://bus-time.centro.org/bustime/api/v1/getvehicles?key=someDeveloperKey&key1=value1&key2=value2
             */
        }
    }
    
    
    //----------------------protocol methods --------------------------//
    
    func getListOfBuses(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, departTime: NSDate)
    {
        
    }
    

    func getListOfBusesToHome(source: CLLocationCoordinate2D, departTime: NSDate) -> [String]
    {
        // give some action   
        self.action = "";
        
        //give required set of key value arguments
        for index in 1...5
        {
            self.arguments["key"] = "value" ;
        }
        
        //generate the request string
        let requestURL = self.request;
    }
    

    func getListOfBusesToWork(source: CLLocationCoordinate2D, departTime: NSDate) -> [String]
    {
        // give some action
        self.action = "";
        
        //give required set of key value arguments
        for index in 1...5
        {
            self.arguments["key"] = "value" ;
        }
        
        //generate the request string
        let requestURL = self.request;
    }

    
    
    //-------------------utility methods ------------------------------//
    
    
}