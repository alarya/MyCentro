//
//  getRoutesModel.swift
//  MyCentro
//
//  Created by Alok Arya on 11/23/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation



class getRoutesModel : NSObject, NSXMLParserDelegate
{
    var elementValue = "";                              // to temporarily store XML element values
    var routesArray = [String]();                       // Holds the uniquely indentified routes
    
    
    func getRoutes(data : NSData) -> [String]
    {
        let xmlData = NSXMLParser.init(data: data ) ;
        xmlData.delegate = self ;
        xmlData.parse();
        
        return routesArray;
    }
    //-------------XML Parser delegate methods -------------------------//
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        //print(elementName);
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
            self.elementValue += string;
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        //print(elementValue);
        if elementName == "rt"
        {
            //cleanup whitespaces
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\n", withString: "");
            self.elementValue = self.elementValue.stringByReplacingOccurrencesOfString("\t", withString: "");
                
            if(self.elementValue[self.elementValue.startIndex] != "A" || self.elementValue[self.elementValue.startIndex] != "R" ) //filtering out routes of Auburn and Rome - not working
            {
                    self.routesArray.append(elementValue);
            }
        }
        elementValue = "";
    }
    
    func parserDidEndDocument(parser: NSXMLParser)
    {
            //print(self.routesArray);
    }
    //-------End of XML Parser delegates --------------------------------//
    
}