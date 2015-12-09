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


//------Generates a URL for API calls-----------//

class URLgenerator : NSObject
{
    //properties related to API calls
    //let developerKey = "2wtwVNZzJ4Wn7tijTSw8yCfFW";     //change this value to update developer key used
    let developerKey = "TCMBNTLMspXmbHF8iqkKpLuAv" ;     //alternate key
    let baseURI = "http://bus-time.centro.org/bustime/api/v1";       //change this to update base URI and version of centro API
    var action = "" ;                                            // execute which action call in the API request
    var arguments = [String : String]() ;               // Stores Key,value arguments to be added in the URL for API call
    
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

}

//------Interacts with Centro API to get data on buses-----------//

/*
*  Does some heavy processing to find data of available
*  buses from a series of chained API calls
*
*/
class CentroBusApiCaller : NSObject, BusModelProtocol, NSXMLParserDelegate{
    
    //var URL = NSURL() ;
    //var URLRequest = NSURLRequest() ;
    let session = NSURLSession.sharedSession();

    
    //properties used in methods
    let acceptableRange = 1000.00 ;                        //change this value to limit the bus stops found within the specified range (meters)
    var source = CLLocation();
    var destination = CLLocation();
    var routesDictionary = [String : Route]();          // maintains route info:   key - route , value - routeinfo
    var routesStopDictionary = [String : [Stop]]();     // maintains Stops info:   key - route , value - Array of Stops
    var predictionsRoutes = [String : [Stop]]();         // stores which possible routes and it's stops match the search criteria
    var stopsInfo = [String : Stop ]() ;             // maintains stops info: key - stopid , value - stop
    var predictionsList = [PredictionObject](); // maintains predicted timings info - key - route, value - predictions for source and dest
    
    
    //----------------------protocol methods --------------------------//
    
    func getListOfBuses(source: CLLocation, destination: CLLocation, controller: BusListController)
    {
        
        //reintialize predictionRoutes for each call
        self.predictionsRoutes.removeAll();
        //reintialize predictionTimes for each call
        self.predictionsList.removeAll();
        
        self.source = source;
        self.destination = destination;
        

            //--------get all routes--------------
            let requestGenerator = URLgenerator();
            requestGenerator.action = "getroutes" ;
            let URL = NSURL.init(string: requestGenerator.request)!;
            let URLRequest = NSURLRequest.init(URL: URL);
            
            
            print("Calling: ");
            print(requestGenerator.request);

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
                    
                    
                    let routesDataParser = RoutesDataParser();
                    self.routesDictionary = routesDataParser.getRoutes(data!);
                    
                    //print("Routes");
                    //print(self.routesDictionary);
                    
                    //Get all stops in each route
                    self.getDirections(controller);
                    
                }
                
            });
            taskGetRoutes.resume();
        //}
    }
    
    
    func getDirections(controller : BusListController)
    {
        //For each route get directions
        for route in self.routesDictionary.keys
        {
            let reqquestGenerator = URLgenerator();
            reqquestGenerator.action = "getdirections" ;
            reqquestGenerator.arguments.removeAll();
            reqquestGenerator.arguments["rt"] = route ;
            let URL = NSURL.init(string: reqquestGenerator.request)!;
            let URLRequest = NSURLRequest.init(URL: URL);
            
            //print("Calling: ");
            //print(reqquestGenerator.request);
            
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
                    
                    //print("Route");
                    //print(route);
                    //print("Direction");
                    //print(direction);
                    
                    //add the directions to routes dictionary
                    if(direction.count == 2)
                    {
                        self.routesDictionary[route]!.dir1 = direction[0];
                        self.routesDictionary[route]!.dir2 = direction[1];
                        
                        //----get stops for each route, dir1-------//
                        self.getStops(route,direction: direction[0], controller: controller);
                    }
                    else
                    {
                        print("Could not parse route direction data")
                    }
                }
            });
            
            taskGetDirection.resume();
        }
        
    }
    
    func getStops(route : String , direction : String, controller: BusListController )
    {
        //get all stops of each {route,direction}
        let requestGenerator = URLgenerator();
        requestGenerator.action = "getstops";
        requestGenerator.arguments.removeAll();
        requestGenerator.arguments["rt"] = route;
        requestGenerator.arguments["dir"] = direction;
        let URL = NSURL.init(string: requestGenerator.request)!;
        let URLRequest = NSURLRequest.init(URL: URL);
        
        //print("Calling: ");
        //print(requestGenerator.request);
        
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
             
                self.getPredictionsRoutes(route, controller: controller);
            }
        });
        
        taskGetStops.resume();
    }

    func getPredictionsRoutes(route: String, controller: BusListController)
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
        
            //add to stopsinfo array
            self.stopsInfo[stop.stpid] = stop ;
            
            //find stops closest to source and destination in a route
            //and save them to be later used for prediction
            let stopLocation = CLLocation.init(latitude: stop.lat, longitude: stop.lon);
            distance = self.source.distanceFromLocation(stopLocation);
            if (distance < closestSourceStopDist && Double(distance) < self.acceptableRange)
            {
                closestSourceStopDist = distance;
                source = stop;
                //print("A possible source was found ----------------");
            }
            distance = self.destination.distanceFromLocation(stopLocation);
            if (distance < closestDestinationStopDist && Double(distance) < self.acceptableRange)
            {
                closestDestinationStopDist = distance;
                dest = stop ;
                //print("A possible destination was found -----------");
            }
        }
            
        //if found two different stops as source and destination
        //add them to possible stops dictionary with key as the route
        if(source.stpid != dest.stpid && source.lat != 0.0 && source.lon != 0.0 && dest.lat != 0.0 && dest.lon != 0.0)
        {
            print("Added possible routes---------------------------");
            source.type = "source";
            self.predictionsRoutes[route] = [source] ;
            dest.type = "dest";
            self.predictionsRoutes[route]?.append(dest);
        }
            
        //print("--------prediction for possible routes-------------");
        //print(self.predictionsRoutes);
        
        self.getPredictionsTimes(route, controller: controller);
    }
        
        
    
    
    func getPredictionsTimes(route: String, controller: BusListController)
    {

        //predictions for each route in predictionsRoutes dictionary
        if( self.predictionsRoutes[route] != nil)
        {
            let requestGenerator = URLgenerator();
            requestGenerator.action = "getpredictions" ;
            //arguments for API call
            var stops = "";
            stops += (self.predictionsRoutes[route]?.first?.stpid)! ;
            stops += ","
            stops += (self.predictionsRoutes[route]?.last?.stpid)! ;
            requestGenerator.arguments["stpid"] = stops;
            requestGenerator.arguments["rt"] = route;
            
            let URL = NSURL.init(string: requestGenerator.request)!;
            let URLRequest = NSURLRequest.init(URL: URL);
            
        
            print("Calling: ");
            print(requestGenerator.request);
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
                    
                    var sourcestpid = "" ;
                    var deststpid = "" ;
                    
                    for stop in self.predictionsRoutes[route]!
                    {
                        if stop.type == "source"
                        {
                            sourcestpid  = stop.stpid ;
                        }
                        else
                        {
                            deststpid = stop.stpid ;
                        }
                    }
                    
                    
                    
                    if(predictions.count != 0)
                    {
                        for (vid,_) in predictions
                        {
                            if(predictions[vid]?.count >= 2)
                            {
                                let predictionObject = PredictionObject();
                                
                                for prediction in predictions[vid]!
                                {
                                    //take 1st two prediction stops as they will be source,dest
                                    // TO - DO : make sure source prd time <= dest prd time
                        
                                    if(prediction.stpid == sourcestpid)
                                    {
                                        predictionObject.sourcestpid = prediction.stpid ;
                                        predictionObject.sourceprdtm = prediction.prdtm ;
                                        predictionObject.sourcestpnm = prediction.stpnm ;
                                        //add location info
                                        predictionObject.sourcelocation = CLLocation.init(latitude: self.stopsInfo[prediction.stpid]!.lat, longitude: self.stopsInfo[prediction.stpid]!.lon);
                                    }
                                    else if prediction.stpid == deststpid
                                    {
                                        predictionObject.deststpid = prediction.stpid ;
                                        predictionObject.destprdtm = prediction.prdtm ;
                                        predictionObject.deststpnm = prediction.stpnm ;
                                        //add location info
                                        predictionObject.destlocation = CLLocation.init(latitude: self.stopsInfo[prediction.stpid]!.lat, longitude: self.stopsInfo[prediction.stpid]!.lon);
                                    }
         
                                    predictionObject.rt = route ;
                                    predictionObject.rtnm = (self.routesDictionary[route]?.rtnm)!;
                                    predictionObject.rtdir = prediction.rtdir;
                                    predictionObject.vid = prediction.vid ;
                                }
                            
                            //added measure to avoid adding prediction object with black source or dest stops
                            if(predictionObject.sourcestpnm != "" && predictionObject.deststpnm != "")
                            {
                                if(self.sourcePrdTimeLessThanDest(predictionObject))
                                {
                                    self.predictionsList.append(predictionObject);
                                }
                            }
                            
                            //print("---------prediction with timings ------------")
                            //print(self.predictionsList);  
                            }
                        }
                        self.returnBusList(controller);
                    }
                    else
                    {
                        //No predictions returned currently
                    }
                    
                }
            });
            
            taskGetPredictions.resume();
        }
    }
    
    func stopsBetweenSourceDest(sourceStpId: String, destStpId: String, route: String, routeDir: String, controller: BusDetailsController)
    {
        let requestGenerator = URLgenerator() ;
        requestGenerator.action = "getstops" ;
        requestGenerator.arguments.removeAll();
        requestGenerator.arguments["rt"] = route;
        requestGenerator.arguments["dir"] = routeDir;
        let URL = NSURL.init(string: requestGenerator.request)!;
        let URLRequest = NSURLRequest.init(URL: URL);
        
        print("Calling: ");
        print(requestGenerator.request);
        
        let taskGetStops : NSURLSessionDataTask = session.dataTaskWithRequest(URLRequest, completionHandler: {
            (data: NSData?,response: NSURLResponse?,error: NSError?) -> Void in
            
            if error != nil
            {
                print("Error in getting stops between specified source and dest");
            }
            else
            {
                //get all stops of a route
                let stopsDataParser = StopsDataParser();
                var stops = stopsDataParser.getStops(data!) ;
                
                //remove stops before source(inclusive)
                var indexOfSource = -1 ;
                var count = 0 ;
                for stop in stops
                {
                    if(stop.stpid == sourceStpId)
                    {
                        indexOfSource = count ;
                        break;
                    }
                    count++;
                }
                if(indexOfSource != -1)
                {
                    stops.removeRange(0...indexOfSource) ;
                }
                
                //remove stops after destination(inclusive)
                var indexOfDest = -1 ;
                count = 0 ;
                for stop in stops
                {
                    if(stop.stpid == destStpId)
                    {
                        indexOfDest = count ;
                        break;
                    }
                    count++;
                }
                if(indexOfDest != -1)
                {
                    stops.removeRange(indexOfDest...stops.count-1) ;
                }
                
                //call controller to draw the route
                controller.drawRoute(stops);
            }
        });
        
        taskGetStops.resume();

    }
    
    func returnBusList(controller: BusListController)
    {
        //session.delegateQueue.waitUntilAllOperationsAreFinished();
        
        print("Sending prediction times to the controller.....");
        
        controller.updateTableView(self.predictionsList);
    }
    
    func sourcePrdTimeLessThanDest(predictionObject: PredictionObject) -> Bool
    {
        let sourceTime = predictionObject.sourceprdtm.componentsSeparatedByString(" ").last ;
        let destTime = predictionObject.destprdtm.componentsSeparatedByString(" ").last ;

        let sourceHour = sourceTime!.componentsSeparatedByString(":").first ;
        let sourceMinutes = sourceTime!.componentsSeparatedByString(":").last ;
        let destHour = destTime!.componentsSeparatedByString(":").first ;
        let destMinutes = destTime!.componentsSeparatedByString(":").last ;
        
        if( Int(sourceHour!)! < Int(destHour!)! )
        {
            return true ;
        }
        else if (Int(sourceHour!)! == Int(destHour!)!)
        {
            if( Int(sourceMinutes!)! <= Int(destMinutes!)! )
            {
                return true ;
            }
        }
        
        return false;
    }
    
    func returnRouteList(controller: RoutesListController)
    {
        //--------get all routes--------------
        let requestGenerator = URLgenerator();
        requestGenerator.action = "getroutes" ;
        let URL = NSURL.init(string: requestGenerator.request)!;
        let URLRequest = NSURLRequest.init(URL: URL);
        
        
        print("Calling: ");
        print(requestGenerator.request);
        
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
                
                
                let routesDataParser = RoutesDataParser();
                let routesListDictionary = routesDataParser.getRoutes(data!);
                
                var routeList = [Route]();
                
                for (_,route) in routesListDictionary
                {
                    routeList.append(route)
                }
                controller.updateTableView(routeList);
            }
            
        });
        taskGetRoutes.resume();
    }
    
    func returnDirectionList(route: String, controller: DirectionsListController)
    {
        let requestGenerator = URLgenerator();
        requestGenerator.action = "getdirections" ;
        requestGenerator.arguments.removeAll();
        requestGenerator.arguments["rt"] = route ;
        let URL = NSURL.init(string: requestGenerator.request)!;
        let URLRequest = NSURLRequest.init(URL: URL);
        
        //print("Calling: ");
        //print(reqquestGenerator.request);
        
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
                
                controller.updateTableView(direction);
            }
        });
        
        taskGetDirection.resume();

    }
    
    func returnStopList(route: String, direction: String, controller: StopsListController)
    {
        //get all stops of each {route,direction}
        let requestGenerator = URLgenerator();
        requestGenerator.action = "getstops";
        requestGenerator.arguments.removeAll();
        requestGenerator.arguments["rt"] = route;
        requestGenerator.arguments["dir"] = direction;
        let URL = NSURL.init(string: requestGenerator.request)!;
        let URLRequest = NSURLRequest.init(URL: URL);
        
        //print("Calling: ");
        //print(requestGenerator.request);
        
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
                
                controller.updateTableView(stops) ;
            }
        });
        
        taskGetStops.resume();
    }
    
    func returnStopPrediction(stop: String, route: String, dir: String, controller: StopPredictionController)
    {
        let requestGenerator = URLgenerator();
        requestGenerator.action = "getpredictions" ;
        //arguments for API call
        requestGenerator.arguments["stpid"] = stop;
        requestGenerator.arguments["rt"] = route;
        
        let URL = NSURL.init(string: requestGenerator.request)!;
        let URLRequest = NSURLRequest.init(URL: URL);
        
        
        print("Calling: ");
        print(requestGenerator.request);
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
                let predictions = predictionsDataParser.getStopPredictions(data!)
                
                if predictions.count == 0
                {
                    controller.updateView(Prediction() );    //sending a blank prediction if no predictions found
                }
                
                for prd in predictions
                {
                    if( prd.stpid == stop &&   prd.rtdir == dir  && prd.rt == route)
                    {
                        controller.updateView(prd);
                        return ;
                    }
                }
                controller.updateView(Prediction()) ;
            }
        });
        
        taskGetPredictions.resume();
    }
    
}