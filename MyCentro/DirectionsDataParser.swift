//
//  getDirectionsModel.swift
//  MyCentro
//
//  Created by Alok Arya on 11/23/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation

/************************************************************
*
* Parses the XML data from the API call to /getpdirections
* returns an array of directions for a route
*
************************************************************/

class DirectionsDataParser : NSObject, NSXMLParserDelegate
{
    var elementValue = "";                              // to temporarily store XML element values
    var directions = [String]();                        // directions array for route
    
    //----get a one way direction of a route -------//
    func getDirection(data : NSData) -> [String]
    {        
        let xmlData = NSXMLParser.init(data: data ) ;
        xmlData.delegate = self ;
        xmlData.parse();

        return directions ;
    }
    
    //-------------XML Parser delegate methods -------------------------//
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        //print(elementName);
        self.elementValue = "";
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        self.elementValue += string;
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        //print(elementValue);
        if elementName == "dir"
        {
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
            self.directions.append(elementValue);
        }

        elementValue = "";
    }
    
    func parserDidEndDocument(parser: NSXMLParser)
    {
        //print(self.routesArray);
    }
    //-------End of XML Parser delegates --------------------------------//
}