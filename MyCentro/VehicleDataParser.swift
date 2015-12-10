//
//  VehicleDataParser.swift
//  MyCentro
//
//  Created by Alok Arya on 12/10/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation



/************************************************************
*
* Parses the XML data from the API call to /getvehicles
* returns vehicle location
*
************************************************************/

class VehicleDataParser : NSObject, NSXMLParserDelegate
{
    var elementValue = "";                              // to temporarily store XML element values
    var vehicle = Vehicle();
    
    func getVehicleInfo(data : NSData) -> Vehicle
    {
        let xmlData = NSXMLParser.init(data: data ) ;
        xmlData.delegate = self ;
        xmlData.parse();
        
        return self.vehicle;
    }
    
    //-------------XML Parser delegate methods -------------------------//
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        self.elementValue = "";
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        self.elementValue += string;
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        //print(elementValue);
        switch(elementName)
        {
        case "vid":
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
            self.vehicle.vid = self.elementValue;
            self.elementValue = "";
            break;
        case "lat":
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
            
            self.vehicle.lat = self.elementValue;
            self.elementValue = "";
            break;
            
        case "lon":
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
            self.vehicle.lon = self.elementValue;
            self.elementValue = "";
            break;
        default:
            break;
        }
        
    }
    
    func parserDidEndDocument(parser: NSXMLParser)
    {
        
    }
    //-------End of XML Parser delegates --------------------------------//
    
}