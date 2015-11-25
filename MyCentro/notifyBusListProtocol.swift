//
//  notifyBusListProtocol.swift
//  MyCentro
//
//  Created by Alok Arya on 11/24/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation


protocol notifyBusListProtocol
{
    
    func notifyBusListAvailable(busList: [String], controller: BusListController);
    
    func notifyBusListNotAvailable(controller: BusListController);
}