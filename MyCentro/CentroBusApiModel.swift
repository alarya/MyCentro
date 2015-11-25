//
//  CentroBusApiModel.swift
//  MyCentro
//
//  Created by Alok Arya on 11/18/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

//------Interacts with Centro API to get data on buses-----------//

/*
 *  Does some heavy processing to find data of available
 *  buses from a series of chained API calls
 *
 */

class CentroBusApiModel : NSObject, BusModelProtocol, NSXMLParserDelegate{
    
    let developerKey = "2wtwVNZzJ4Wn7tijTSw8yCfFW";     //change this value to update developer key used
    let baseURI = "http://bus-time.centro.org/bustime/api/v1";       //change this to update base URI and version of centro API
    var action = "" ;                                            // execute which action call in the API request
    var arguments = [String : String]() ;               // Stores Key,value arguments to be added in the URL for API call
    let acceptableRange = 5000.00 ;                        //change this value to limit the bus stops found within the specified range (meters)
    var routesArray = [String]();                       // stores all uniquely identified routes
    let routesModel = getRoutesModel();                 // get all the routes tracked by the Server
    var delegate: notifyBusListProtocol? = nil;
    var possibleStops = [String : [String]]();          //stores the set of <route,[stopsource,stopdest]> for each call to getListOfBuses
    var stopLocations = [String : CLLocation]();          //maintain stop locations dictionary
    
    var request : String                                // the effective URL for API including all components
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
            
            /* Sample response string
             *
             *   http://bus-time.centro.org/bustime/api/v1/getvehicles?key=someDeveloperKey&key1=value1&key2=value2
             */
        }
    }
    
    
    //----------------------protocol methods --------------------------//
    
    func getListOfBuses(source: CLLocation, destination: CLLocation)
    {
        
        var URL : NSURL ;
        var URLRequest : NSURLRequest ;
        let session = NSURLSession.sharedSession();
        self.possibleStops = [String : [String]](); //clear existing property value for a new call
        
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
                                        //get all stops of a route
                                        let stopsModel = getStopsModel();
                                        let stops = stopsModel.getStops(data!);
                                        
                                        print("================Route===============");
                                        print(route);
                                        print("----------------Stops---------------");
                                        
                                        
                                        var closestSourceStopDist = CLLocationDistance.infinity;
                                        var closestDestinationStopDist = CLLocationDistance.infinity;
                                        var sourcestpid = "";
                                        var deststpid = "";
                                        var distance = CLLocationDistance();
                                        for stop in stops
                                        {
                                            print(stop.stpid);
                                            print(stop.stpnm);
                                            print(stop.lat);
                                            print(stop.lon);
                                            
                                            //add to stop->location dictionary for later use
                                            let stopLocation = CLLocation.init(latitude: stop.lat, longitude: stop.lon);
                                            self.stopLocations[stop.stpid] = stopLocation;
                                            
                                            //find stops closest to source and destination in a route
                                            //and save them to be later used for prediction
                                            distance = source.distanceFromLocation(stopLocation);
                                            if (distance < closestSourceStopDist && Double(distance) < self.acceptableRange)
                                            {
                                                closestSourceStopDist = distance;
                                                sourcestpid = stop.stpid ;
                                                print("A possible source was found ----------------------------");
                                            }
                                            distance = destination.distanceFromLocation(stopLocation);
                                            if (distance < closestDestinationStopDist && Double(distance) < self.acceptableRange)
                                            {
                                                closestDestinationStopDist = distance;
                                                deststpid = stop.stpid ;
                                                print("A possible destination was found ----------------------------");
                                            }
                                        }
                                        
                                        //if found two different stops as source and destination
                                        //add them to possible stops dictionary with key as the route
                                        if(sourcestpid != deststpid)
                                        {
                                            self.possibleStops[route]?.append(sourcestpid) ;
                                            self.possibleStops[route]?.append(deststpid);
                                        }
                                        
                                        
                                        
                                    }
                                });
                                
                                taskGetStops.resume();
                            }
                        });
                        
                        taskGetDirection.resume();
                    }
                    
                    //After all routes have been analyzed we'll have the data
                    //of list of possibleStops
                    //call get predictions for these routes,[stops]
                    self.getPredictions();
                }
            });
        
        
        taskGetRoutes.resume();
        
    }

    func getPredictions()
    {
        var URL : NSURL ;
        var URLRequest : NSURLRequest ;
        let session = NSURLSession.sharedSession();
        
        self.action = "getpredictions" ;
        
        //predictions for each route in possibleStops dictionary
        for route in possibleStops.keys
        {
            arguments.removeAll();
            var stops = "";
            stops += (possibleStops[route]?.removeAtIndex(0))!;
            stops += ","
            stops += (possibleStops[route]?.removeAtIndex(1))!;
            
            URL = NSURL.init(string: self.request)!;
            URLRequest = NSURLRequest.init(URL: URL);
            
        
            print("Calling: ");
            print(self.request);
            print("\n");
            
            let taskGetPredictions : NSURLSessionDataTask = session.dataTaskWithRequest(URLRequest, completionHandler: {
                (data: NSData?,response: NSURLResponse?,error: NSError?) -> Void in
                
                if error != nil
                {
                    //handle error
                    print("Error in getting predictions");
                    print(error?.domain);
                    print(error?.description);
                    print("\n");
                    
                    
                }
                else
                {
                    let predictionsModel = getPredictionsModel();
                    let predictions = predictionsModel.getPredictions(data!);
                    
                    for prediction in predictions
                    {
                        print("=====prediction=====");
                        print(prediction.stpid);
                        print(prediction.rt);
                        print(prediction.prdtm);
                        
                        prediction.location = self.stopLocations[prediction.stpid]!;
                    }
                }
            });
            
            taskGetPredictions.resume();
        }
    }
    func returnBusList()
    {
        
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