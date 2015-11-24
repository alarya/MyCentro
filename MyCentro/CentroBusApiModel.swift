//
//  CentroBusApiModel.swift
//  MyCentro
//
//  Created by Alok Arya on 11/18/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import CoreLocation

//------Interacts with Centro API to get data on buses

class CentroBusApiModel : NSObject, BusModelProtocol, NSXMLParserDelegate{
    
    let developerKey = "2wtwVNZzJ4Wn7tijTSw8yCfFW";     //change this value to update developer key used
    let baseURI = "http://bus-time.centro.org/bustime/api/v1";       //change this to update base URI and version of centro API
    var action = "" ;                                            // execute which action call in the API request
    var arguments = [String : String]() ;               // Stores Key,value arguments to be added in the URL for API call
    let acceptableRange = 2.00 ;                        //change this value to limit the bus stops found within the specified range
    var routesArray = [String]();                       // stores all uniquely identified routes
    let routesModel = getRoutesModel();                 // get all the routes tracked by the Server
    //var directionsModel : getDirectionsModel = nil;        // given a route get the name of a one direction
    //var stopsModel? : getStopsModel = nil;
    
    var request : String                                // the effective API including all components
    {
        get
        {
            var argumentsStringified = "";
            for(key, value) in self.arguments{
                argumentsStringified += "&" ;
                argumentsStringified += key;
                argumentsStringified += "=" ;
                argumentsStringified += value ;
                
            }
            
            //generate request string
            argumentsStringified =  baseURI + "/" + self.action + "?" + "key" + "=" + self.developerKey + argumentsStringified ;
            //spaces in a URL need to be replaced by %20 for being well formed
            return argumentsStringified.stringByReplacingOccurrencesOfString(" ", withString: "%20");
            
            /* Sample string 
             *
             *   http://bus-time.centro.org/bustime/api/v1/getvehicles?key=someDeveloperKey&key1=value1&key2=value2
             */
        }
    }
    
    
    //----------------------protocol methods --------------------------//
    
    func getListOfBuses(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, departTime: NSDate) -> [String]
    {
        let result = [""];
        
        var URL : NSURL ;
        var URLRequest : NSURLRequest ;
        let session = NSURLSession.sharedSession();
        
        //get all routes
        self.action = "getroutes" ;
        arguments.removeAll();
        URL = NSURL.init(string: self.request)!;
        URLRequest = NSURLRequest.init(URL: URL);
        
        
        print("Calling: ");
        print(self.request);
        print("\n");
        let taskGetRoutes : NSURLSessionDataTask = session.dataTaskWithRequest(URLRequest, completionHandler: {
            (data: NSData?,response: NSURLResponse?,error: NSError?) -> Void in
            
                if error != nil
                {
                    //handle error
                    print("Error in getting routes");
                    print(error?.domain);
                    print(error?.description);
                    print("\n");
                    
                    
                }
                else
                {
                    print("Routes");
                    
                    self.routesArray = self.routesModel.getRoutes(data!);
                    
                    print(self.routesArray);
                    
                    //For each route get a one way direction and it's set of stops
                    for route in self.routesArray
                    {
                        self.action = "getdirections" ;
                        self.arguments.removeAll();
                        self.arguments["rt"] = route ;
                        URL = NSURL.init(string: self.request)!;
                        URLRequest = NSURLRequest.init(URL: URL);
                        
                        print("Calling: ");
                        print(self.request);
                        
                        let taskGetDirection : NSURLSessionDataTask = session.dataTaskWithRequest(URLRequest, completionHandler: {
                            (data: NSData?,response: NSURLResponse?,error: NSError?) -> Void in
                            
                            if error != nil
                            {
                                print("Error in getting direction");
                            }
                            else
                            {
                                let directionsModel = getDirectionsModel();
                                let direction = directionsModel.getDirection(data!);
                                
                                print("Route");
                                print(route);
                                print("Direction");
                                print(direction);
                                
                                //get all stops of each {route,direction}
                                self.action = "getstops";
                                self.arguments.removeAll();
                                self.arguments["rt"] = route;
                                self.arguments["dir"] = direction;
                                URL = NSURL.init(string: self.request)!;
                                URLRequest = NSURLRequest.init(URL: URL);
                                
                                print("Calling: ");
                                print(self.request);
                                
                                let taskGetStops : NSURLSessionDataTask = session.dataTaskWithRequest(URLRequest, completionHandler: {
                                    (data: NSData?,response: NSURLResponse?,error: NSError?) -> Void in
                                    
                                    if error != nil
                                    {
                                        print("Error in getting direction");
                                    }
                                    else
                                    {
                                        let stopsModel = getStopsModel();
                                        let stops = stopsModel.getStops(data!);
                                        
                                        print("================Route===============");
                                        print(route);
                                        print("----------------Stops---------------");
                                        for stop in stops{
                                            print(stop.stpid);
                                            print(stop.stpnm);
                                            print(stop.lat);
                                            print(stop.lon);
                                        }
                                    }
                                });
                                
                                taskGetStops.resume();
                            }
                        });
                        
                        taskGetDirection.resume();
                    }
                }
            
            }) ;
        
        
        taskGetRoutes.resume();
        
        return result;
    }
    
    
    //------------End of Parser delegate methods ------------------------//
    
    /*
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

 */
    
    //-------------------utility methods ------------------------------//
    
    
}