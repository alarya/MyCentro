//
//  getPredictions.swift
//  MyCentro
//
//  Created by Alok Arya on 11/24/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import CoreLocation

/************************************************************
 *
 * Parses the XML data from the API call to /getpredictions
 *
 ************************************************************/

class getPredictionsModel : NSObject, NSXMLParserDelegate
{
    var elementValue = "";                              // to temporarily store XML element values
    var predictions = [prediction]();
    var predictioninfo = prediction() ;
    
    func getPredictions(data : NSData) -> [prediction]
    {
        let xmlData = NSXMLParser.init(data: data ) ;
        xmlData.delegate = self ;
        xmlData.parse();
        
        return predictions ;
    }
    
    //-------------XML Parser delegate methods -------------------------//
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        //start a new tuple
        if elementName == "stop"{
            self.predictioninfo = prediction();
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
        case "prd":
            predictions.append(predictioninfo);
            self.elementValue = "";
            break;
        case "stpid":
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
            self.predictioninfo.stpid = self.elementValue;
            self.elementValue = "";
            break;
        case "prdtm":
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
            self.predictioninfo.prdtm = self.elementValue;
            self.elementValue = "";
            break;
        case "rt":
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
            self.predictioninfo.rt = self.elementValue;
            self.elementValue = "";
            break;
        case "stpnm":
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
            self.predictioninfo.stpnm = self.elementValue;
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

class prediction: NSObject {
    var stpid = "" ;
    var rt = "";
    var prdtm = "";
    var stpnm = "";
    var location = CLLocation.init(latitude: 0.0, longitude: 0.0);
}