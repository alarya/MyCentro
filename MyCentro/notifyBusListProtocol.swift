//
//  notifyBusListProtocol.swift
//  MyCentro
//
//  Created by Alok Arya on 11/24/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import  UIKit




protocol notifyBusListProtocol
{
    
    func notifyBusListAvailable(busList: [String : [Prediction]], controller: UIViewController);
    
    //func notifyBusListNotAvailable(controller: BusListController);
}