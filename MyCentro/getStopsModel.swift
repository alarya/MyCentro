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
*
************************************************************/

class getStopsModel : NSObject, NSXMLParserDelegate
{
    var elementValue = "";                              // to temporarily store XML element values
    var stops = [stop]();
    var stopinfo = stop() ;
    
    func getStops(data : NSData) -> [stop]
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
            self.stopinfo = stop();
        }
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
                stops.append(stopinfo);
                self.elementValue = "";
                break;
            case "stpid":
                //cleanup whitespaces
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
                self.stopinfo.stpid = self.elementValue;
                self.elementValue = "";
                break;
            case "stpnm":
                //cleanup whitespaces
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
                self.stopinfo.stpnm = self.elementValue;
                self.elementValue = "";
                break;
            case "lat":
                //cleanup whitespaces
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
                if let latitude = Double(self.elementValue){
                    self.stopinfo.lat = latitude ;
                }
                else{
                    self.stopinfo.lat = 0.0;
                }
                
                self.elementValue = "";
                break;
            case "lon":
                //cleanup whitespaces
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
                if let longitude  = Double(self.elementValue){
                    self.stopinfo.lon = longitude;
                }
                else{
                    self.stopinfo.lon = 0.0;
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

class stop: NSObject {
    var stpid = "" ;
    var stpnm = "";
    var lat : Double = 0.0;
    var lon : Double = 0.0;
}