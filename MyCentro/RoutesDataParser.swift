//
//  getRoutesModel.swift
//  MyCentro
//
//  Created by Alok Arya on 11/23/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation

/************************************************************
*
* Parses the XML data from the API call to /getproutes
* returns a dictionary of all the routes being tracked
*
************************************************************/

class RoutesDataParser : NSObject, NSXMLParserDelegate
{
    var elementValue = "";                              // to temporarily store XML element values
    var routesDictionary = [String : Route]();          // <route, routeInfo>
    var route = Route();
    
    func getRoutes(data : NSData) -> [String : Route]
    {        
        let xmlData = NSXMLParser.init(data: data ) ;
        xmlData.delegate = self ;
        xmlData.parse();
        
        return self.routesDictionary;
    }
    
    //-------------XML Parser delegate methods -------------------------//
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        //start a new tuple
        if elementName == "route"
        {
            self.route = Route.init();
        }
        
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
            case "route":
                self.routesDictionary[route.rt] = self.route;
                self.elementValue = "";
                break;
            case "rt":
                //cleanup whitespaces
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
                
                //if(self.elementValue[self.elementValue.startIndex] != "A" || self.elementValue[self.elementValue.startIndex] != "R" ) //filtering out routes of Auburn and Rome - not working
                //{
                self.route.rt = self.elementValue;
                self.elementValue = "";
                break;
                //}
            case "rtnm":
                //cleanup whitespaces
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
                self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
            
                self.route.rtnm = self.elementValue;
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