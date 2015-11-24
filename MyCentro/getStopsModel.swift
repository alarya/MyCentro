//
//  getStopsModel.swift
//  MyCentro
//
//  Created by Alok Arya on 11/23/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation

struct stop
{
    var stpid = 0 ;
    var stpnm = "";
    var lat = 0 ;
    var lon = 0;
}

class getStopsModel : NSObject, NSXMLParserDelegate
{
    var elementValue = "";                              // to temporarily store XML element values
    var stops = [stop]();
    var stopinfo = stop() ;
    
    func getStops(data : NSData) -> [stop]
    {
        return stops ;
    }
    
    //-------------XML Parser delegate methods -------------------------//
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        //start a new tuple
        if elementName == "stop"{
            stopinfo = stop();
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        self.elementValue += string;
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        //add the stop to the collection of stops
        if elementName == "stop"
        {
            stops.append(stopinfo);
        }
        else if elementName == "stpid"
        {
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
            self.stopinfo.stpid = Int(self.elementValue)!;
        }
        else if elementName == "stpnm"
        {
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
            self.stopinfo.stpnm = self.elementValue;
        }
        else if elementName == "lat"
        {
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
            self.stopinfo.lat = Int(self.elementValue)!;
        }
        else if elementName == "lon"
        {
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
            self.stopinfo.lon = Int(self.elementValue)!;
        }
        elementValue = "";
    }
    
    func parserDidEndDocument(parser: NSXMLParser)
    {
        //print(self.routesArray);
    }
    //-------End of XML Parser delegates --------------------------------//
}