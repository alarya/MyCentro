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

class CentroBusApiCaller : NSObject, BusModelProtocol, NSXMLParserDelegate{
    
    
    //properties related to API calls
    let developerKey = "2wtwVNZzJ4Wn7tijTSw8yCfFW";     //change this value to update developer key used
    let baseURI = "http://bus-time.centro.org/bustime/api/v1";       //change this to update base URI and version of centro API
    var action = "" ;                                            // execute which action call in the API request
    var arguments = [String : String]() ;               // Stores Key,value arguments to be added in the URL for API call
    var URL = NSURL() ;
    var URLRequest = NSURLRequest() ;
    let session = NSURLSession.sharedSession();

    
    //properties used in methods
    let acceptableRange = 5000.00 ;                        //change this value to limit the bus stops found within the specified range (meters)
    var source = CLLocation();
    var destination = CLLocation();
    var routesDictionary = [String : Route]();          // maintains route info:   key - route , value - routeinfo (should not change the each call)
    var routesStopDictionary = [String : [Stop]]();     // maintains Stops info:   key - route , value - Array of Stops (should not change for each call)
    var predictionsRoutes = [String : [String : Stop]]();         // stores which possible routes and it's stops match the search criteria (changes for each call)
    //var predictionsTimes = [String : [Stop : Prediction]]();     // stores prediction times of source and destination stops (changes for each call)
    var predictionsTimes = [Prediction]();
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
        
        //reintialize predictionRoutes for each call
        self.predictionsRoutes.removeAll();
        //reintialize predictionTimes for each call
        self.predictionsTimes.removeAll();
        
        self.source = source;
        self.destination = destination;
        
        //check if routes data already exists from previous calls
        if(routesDictionary.count != 0)
        {
            //self.getPredictionsRoutes();     //directly get predictions NEED TO GET BACK TO THIS CASE
        }
        //else get the data
        else
        {
            //--------get all routes--------------
            self.action = "getroutes" ;
            arguments.removeAll();
            URL = NSURL.init(string: self.request)!;
            URLRequest = NSURLRequest.init(URL: URL);
            
            
            print("Calling: ");
            print(self.request);

            let taskGetRoutes : NSURLSessionDataTask = session.dataTaskWithRequest(URLRequest, completionHandler: {
                (data: NSData?,response: NSURLResponse?,error: NSError?) -> Void in
                
                //----call to getroutes fails ------
                if error != nil
                {
                    //handle error
                    print("Error in getting routes");
                    print(error?.domain);
                    print(error?.description);
                    print("\n");
                    
                    
                }
                //----call to getroutes  succeeds ----
                else
                {
                    print("Routes");
                    
                    let routesDataParser = RoutesDataParser();
                    self.routesDictionary = routesDataParser.getRoutes(data!);
                    
                    print(self.routesDictionary);
                    
                    //Get all stops in each route
                    self.getDirections();
                    
                }
                
            });
            taskGetRoutes.resume();
        }
    }
    
    
    func getDirections()
    {
        //For each route get directions
        for route in self.routesDictionary.keys
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
                    let directionsDataParser = DirectionsDataParser();
                    let direction = directionsDataParser.getDirection(data!);
                    
                    print("Route");
                    print(route);
                    print("Direction");
                    print(direction);
                    
                    //add the directions to routes dictionary
                    if(direction.count == 2)
                    {
                        self.routesDictionary[route]!.dir1 = direction[0];
                        self.routesDictionary[route]!.dir2 = direction[1];
                        
                        //----get stops for each route, dir1-------//
                        self.getStops(route,direction: direction[0]);
                    }
                    else
                    {
                        print("Could not parse route direction data")
                    }
                }
            });
            
            taskGetDirection.resume();
        }
        
        //After all routes have been analyzed we'll have the data
        //of list of possibleStops
        //call get predictions for these routes,[stops]
        //self.getPredictions();
    }
    
    func getStops(route : String , direction : String )
    {
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
                print("Error in getting stops");
            }
            else
            {
                //get all stops of a route
                let stopsDataParser = StopsDataParser();
                let stops = stopsDataParser.getStops(data!);
                
                //print("================Route===============");
                //print(route);
                //print("----------------Stops---------------");
                //print(stops);
                
                //add it routesStopDictionary
                self.routesStopDictionary[route] = stops ;
             
                self.getPredictionsRoutes(route);
            }
        });
        
        taskGetStops.resume();
    }

    func getPredictionsRoutes(route: String)
    {

        var closestSourceStopDist = CLLocationDistance.infinity;
        var closestDestinationStopDist = CLLocationDistance.infinity;
        var source = Stop();
        var dest = Stop();
        var distance = CLLocationDistance();
            
        for stop in routesStopDictionary[route]!
        {
            //print(stop.stpid);
            //print(stop.stpnm);
            //print(stop.lat);
            //print(stop.lon);
        
            
            //find stops closest to source and destination in a route
            //and save them to be later used for prediction
            let stopLocation = CLLocation.init(latitude: stop.lat, longitude: stop.lon);
            distance = self.source.distanceFromLocation(stopLocation);
                if (distance < closestSourceStopDist && Double(distance) < self.acceptableRange)
                {
                    closestSourceStopDist = distance;
                    source = stop;
                    //print("A possible source was found ----------------------------");
                }
                distance = self.destination.distanceFromLocation(stopLocation);
                if (distance < closestDestinationStopDist && Double(distance) < self.acceptableRange)
                {
                    closestDestinationStopDist = distance;
                    dest = stop ;
                    //print("A possible destination was found ----------------------------");
                }
            }
            
            //if found two different stops as source and destination
            //add them to possible stops dictionary with key as the route
            if(source.stpid != dest.stpid)
            {
                print("Added possible routes---------------------------")
                //if(self.predictionsRoutes[route] == nil)
                //{
                //    self.predictionsRoutes[route] = [source] ;
                //    self.predictionsRoutes[route]?.append(dest);
                //}
                //else
                //{
                //    self.predictionsRoutes[route]?.append(source) ;
                //    self.predictionsRoutes[route]?.append(dest);

                //}
                var _stop = [String :Stop]();
                _stop["source"] = source ;
                _stop["dest"] = dest ;
                self.predictionsRoutes[route] = _stop;

            }
            
            //print("--------prediction for possible routes-------------");
            //print(self.predictionsRoutes);
        
        self.getPredictionsTimes(route);
    }
        
        
    
    
    func getPredictionsTimes(route: String)
    {

        //predictions for each route in predictionsRoutes dictionary
        if( predictionsRoutes[route] != nil)
        {
            self.action = "getpredictions" ;
            //arguments for API call
            self.arguments.removeAll();                        //IS A COMMON RESOURCE BEING USED IN MULTIPLE THREADS : NEED TO LOOK INTO THIS 
            var stops = "";
            var _stops:[String:Stop] = predictionsRoutes[route]!;
            stops += (_stops["source"]?.stpid)!;
            stops += ","
            stops += (_stops["dest"]?.stpid)!;
            self.arguments["stpid"] = stops;
            
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
                    let predictionsDataParser = PredictionsDataParser();
                    let predictions = predictionsDataParser.getPredictions(data!);
                    
                    for prediction in predictions
                    {
                        print("=====prediction=====");
                        print(prediction.stpid);
                        print(prediction.rt);
                        print(prediction.prdtm);
                    }
                    
                    
                    self.predictionsTimes = predictions;
                    
                    print("---------prediction with timings ------------")
                    print(self.predictionsTimes);
                    self.returnBusList();
                    
                }
            });
            
            taskGetPredictions.resume();
        }
    }
    
    func returnBusList()
    {
        print("Sending prediction times to the controller.....");
    }
    
}