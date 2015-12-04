//
//  BusModelProtocol.swift
//  MyCentro
//
//  Created by Alok Arya on 11/18/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import CoreLocation

protocol BusModelProtocol
{
    
    //methods for this protocol
    
    
    //1. Get list of Buses for a (source,destination,time)
    func getListOfBuses(source: CLLocation, destination: CLLocation, controller: BusListController);

    //2. Get stops b/w source and destination of a route 
    func stopsBetweenSourceDest(sourceStpId: String, destStpId: String, route: String, routeDir: String, controller: BusDetailsController)
}