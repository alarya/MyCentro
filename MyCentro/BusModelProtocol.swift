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
    func getListOfBuses(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, departTime: NSDate) -> [String]  ;

    
    //2. Get list of Buses to home
    func getListOfBusesToHome(source: CLLocationCoordinate2D, departTime: NSDate) -> [String] ;
    
    //3. Get list of Buses to WOrk
    func getListOfBusesToWork(source: CLLocationCoordinate2D, departTime: NSDate) -> [String] ;
}