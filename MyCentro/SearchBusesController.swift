//
//  SearchBuses.swift
//  MyCentro
//
//  Created by Alok Arya on 11/27/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import AddressBookUI
import Contacts

class SearchBusesController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate,
                                UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var sourceInput: UITextField!  
    
    @IBOutlet weak var destInput: UITextField!
    
    @IBOutlet weak var sourceSuggestions: UITableView!
 
    @IBOutlet weak var destSuggestions: UITableView!
    
    var sourceSuggestionsArray = [CLPlacemark]();
    
    var destSuggestionsArray = [CLPlacemark]();
    
    var locationLookUp = CLGeocoder();
    
    var locationManager = CLLocationManager();
    
    var currentLocation = CLLocation.init(latitude: 0.0, longitude: 0.0);
    
    var sourceLocationSelected = CLLocation.init(latitude: 0.0, longitude: 0.0);

    var destLocationSelected = CLLocation.init(latitude: 0.0, longitude: 0.0);
    
    convenience init()
    {
        self.init(nibName: nil, bundle: nil);
    }
    //default initializer
    required init(coder aDecoder: NSCoder)
    {
        
        super.init(coder: aDecoder)!;
    }
    //designated initializer
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
    
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        sourceInput.delegate = self ;
        destInput.delegate = self ;
        locationManager.delegate = self ;
        sourceSuggestions.delegate = self ;
        destSuggestions.delegate = self ;
        sourceSuggestions.dataSource = self ;
        destSuggestions.dataSource = self ;
        locationManager.startUpdatingLocation();
        
        sourceSuggestions.hidden = true;
        destSuggestions.hidden = true;
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //----------------UITableView delegate and datasource protocol methods ------------//
    
    //func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    //{
    //    return 60.0 ;
    //}
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if tableView == sourceSuggestions
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("sourceSuggestionListCell") ;
            var address = "";
            if self.sourceSuggestionsArray[indexPath.row].thoroughfare != nil
            {
                address += self.sourceSuggestionsArray[indexPath.row].thoroughfare! ;
                address += ", ";
            }
            if self.sourceSuggestionsArray[indexPath.row].subThoroughfare != nil
            {
                address += self.sourceSuggestionsArray[indexPath.row].subThoroughfare! ;
                address += ", ";
            }
            if self.sourceSuggestionsArray[indexPath.row].locality != nil
            {
                address += self.sourceSuggestionsArray[indexPath.row].locality! ;
                address += ", " ;
            }
            if self.sourceSuggestionsArray[indexPath.row].subLocality != nil
            {
                address += self.sourceSuggestionsArray[indexPath.row].subLocality! ;
                address += ", ";
            }
            if self.sourceSuggestionsArray[indexPath.row].administrativeArea != nil
            {
                address += self.sourceSuggestionsArray[indexPath.row].administrativeArea! ;
                address += ", " ;
            }
            address += self.sourceSuggestionsArray[indexPath.row].country! ;
            
            cell!.textLabel?.text = address ;
            
            return cell! ;
        }
        else if tableView == destSuggestions
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("destSuggestionListCell") ;
            
            var address = "";
            if self.destSuggestionsArray[indexPath.row].thoroughfare != nil
            {
                address += self.destSuggestionsArray[indexPath.row].thoroughfare! ;
                address += ", ";
            }
            if self.destSuggestionsArray[indexPath.row].subThoroughfare != nil
            {
                address += self.destSuggestionsArray[indexPath.row].subThoroughfare! ;
                address += ", ";
            }
            if self.destSuggestionsArray[indexPath.row].locality != nil
            {
                address += self.destSuggestionsArray[indexPath.row].locality! ;
                address += ", " ;
            }
            if self.destSuggestionsArray[indexPath.row].subLocality != nil
            {
                address += self.destSuggestionsArray[indexPath.row].subLocality! ;
                address += ", ";
            }
            address += self.destSuggestionsArray[indexPath.row].administrativeArea! ;
            address += ", " ;
            address += self.destSuggestionsArray[indexPath.row].country! ;
            
            cell!.textLabel?.text = address ;
            
            return cell!;
        }
        
        return UITableViewCell.init();
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(tableView == sourceSuggestions)
        {
            //limit suggestions to only 4 addresses
            if sourceSuggestionsArray.count > 7
            {
                return 7 ;
            }
            else
            {
                return sourceSuggestionsArray.count ;
            }
        }
            
        else if (tableView == destSuggestions)
        {
            if destSuggestionsArray.count > 7
            {
                return 7;
            }
            else
            {
                return destSuggestionsArray.count ;
            }
        }
        return 0;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if(tableView == sourceSuggestions)
        {
            self.sourceLocationSelected = self.sourceSuggestionsArray[indexPath.row].location! ;
            self.sourceInput.text = self.tableView(tableView, cellForRowAtIndexPath: indexPath).textLabel!.text;
            self.sourceSuggestions.hidden = true ;
        }
        else if (tableView == destSuggestions)
        {
            self.destLocationSelected = self.destSuggestionsArray[indexPath.row].location! ;
            self.destInput.text = self.tableView(tableView, cellForRowAtIndexPath: indexPath).textLabel!.text;
            self.destSuggestions.hidden = true ;
        }

    }
    //----------------End of UITableView delegate and datasource protocol methods ------//
    
    //------------UITextField delegate methods ----------------------------------------//
    func textFieldDidBeginEditing(textField: UITextField)
    {
        
    }

    @IBAction func sourceTextChanged(sender: UITextField)
    {
        if sourceInput.text?.characters.count > 5
        {
            self.locationLookUp.geocodeAddressString(sourceInput.text!, completionHandler: { (placemarks:[CLPlacemark]?, error: NSError?) -> Void in
                
                if error != nil{
                    
                    //handler error
                }
                else
                {
                    self.sourceSuggestionsArray.removeAll();
                    
                    self.sourceSuggestionsArray =  placemarks! ;
                    
                    self.sourceSuggestions.hidden = false;
                    
                    self.sourceSuggestions.reloadData();
                }
            });
        }
        else
        {
            self.sourceSuggestionsArray.removeAll();
            
            self.sourceSuggestions.hidden = true ;
        }
    }
    
    @IBAction func destTextChanged(sender: UITextField)
    {
        if destInput.text?.characters.count > 5
        {
            self.locationLookUp.geocodeAddressString(destInput.text!, completionHandler: { (placemarks:[CLPlacemark]?, error: NSError?) -> Void in
                
                if error != nil{
                    
                    //handler error
                }
                else
                {
                    self.destSuggestionsArray.removeAll();
                    
                    self.destSuggestionsArray =  placemarks! ;

                    self.destSuggestions.hidden = false;
                    
                    self.destSuggestions.reloadData();
                }
            });

        }
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        if textField == sourceInput
        {
            //self.sourceSuggestions.hidden = true;
            self.sourceSuggestions.hidden = true;
        }
        else if textField == destInput
        {
            //self.destSuggestions.hidden = true;
            self.destSuggestions.hidden = true;
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        return true;
    }
    //------------End of UITextField delegate methods --------------------------------//
    
    //------------CLLocationManager delegate methods -------------------------------//

    //update current location if available
    func locationManager(manager: CLLocationManager,didUpdateLocations locations: [CLLocation])
    {
        self.currentLocation = locations.last! ;
    }
    
    //----------End of CLLocationManager delegate methods ----------------------------//
}