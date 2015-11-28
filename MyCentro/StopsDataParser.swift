//
//  getStopsModel.swift
//  MyCentro
//
//  Created by Alok Arya on 11/23/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation


/************************************************************
*
* Parses the XML data from the API call to /getpstops
* returns an array of stops for a route
*
************************************************************/

class StopsDataParser : NSObject, NSXMLParserDelegate
{
    var elementValue = "";          // to temporarily store XML element values
    var stops = [Stop]();          // Array of stops for a route
    var stop = Stop() ;
    
    func getStops(data : NSData) -> [Stop]
    {        
        let xmlData = NSXMLParser.init(data: data ) ;
        xmlData.delegate = self ;
        xmlData.parse();
 
        return stops ;
    }
    
    //-------------XML Parser delegate methods -------------------------//
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        //start a new tuple
        if elementName == "stop"{
            self.stop = Stop();
        }
        
        self.elementValue = "";
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        self.elementValue += string;
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        //add the stop to the collection of stops
        switch(elementName)
        {
            case "stop":
                self.stops.append(self.stop);
                self.elementValue = "";
                break;
            case "stpid":
                //cleanup whitespaces
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
                self.stop.stpid = self.elementValue;
                self.elementValue = "";
                break;
            case "stpnm":
                //cleanup whitespaces
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
                self.stop.stpnm = self.elementValue;
                self.elementValue = "";
                break;
            case "lat":
                //cleanup whitespaces
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
                if let latitude = Double(self.elementValue){
                    self.stop.lat = latitude ;
                }
                else{
                    self.stop.lat = 0.0;
                }
                
                self.elementValue = "";
                break;
            case "lon":
                //cleanup whitespaces
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
                if let longitude  = Double(self.elementValue){
                    self.stop.lon = longitude;
                }
                else{
                    self.stop.lon = 0.0;
                }
                
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

