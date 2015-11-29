//
//  DataModels.swift
//  MyCentro
//
//  Created by Alok Arya on 11/25/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import CoreLocation


class Route: NSObject
{
    var rt = "" ;
    var rtnm = "" ;
    var dir1 = "" ;
    var dir2 = "" ;
}

class Stop: NSObject
{
    var stpid = "" ;
    var stpnm = "";
    var lat : Double = 0.0;
    var lon : Double = 0.0;
    var type = "" ;          //source or dest
}

class Prediction: NSObject
{
    var stpid = "" ;
    var rt = "" ;
    var rtdir = "";
    var prdtm = "" ;
    var stpnm = "" ;
    var vid = "" ;
    var location = CLLocation.init(latitude: 0.0, longitude: 0.0);
}

class PredictionObject : NSObject
{
    var sourcestpid = "" ;
    var deststpid = "" ;
    var rt = "" ;
    var rtdir = "";
    var rtnm = "";
    var sourceprdtm = "" ;
    var destprdtm = "" ;
    var sourcestpnm = "" ;
    var deststpnm = "" ;
    var vid = "" ;
    var sourcelocation = CLLocation.init(latitude: 0.0, longitude: 0.0);
    var destlocation = CLLocation.init(latitude: 0.0, longitude: 0.0);
}

class BusDetails: NSObject
{
    var sourceName = "";
    var sourceLocation = CLLocation.init(latitude: 0.0, longitude: 0.0);
    var sourceTime = "";
    var destName = "";
    var destLocation = CLLocation.init(latitude: 0.0, longitude: 0.0);
    var destTime = "";
    var intermediateLocations = [CLLocation]();
}