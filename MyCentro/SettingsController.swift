//
//  SettingsController.swift
//  MyCentro
//
//  Created by Alok Arya on 12/4/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


class SettingsController : UIViewController, UITextFieldDelegate,
                            UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var homeInput: UITextField!
    
    @IBOutlet weak var workInput: UITextField!
    
    @IBOutlet weak var homeSuggestions: UITableView!
    
    @IBOutlet weak var workSuggestions: UITableView!
    
    //@IBOutlet weak var rangeInput: UITextField!
    
    var homeSuggestionsArray = [CLPlacemark]();
    
    var workSuggestionsArray = [CLPlacemark]();
    
    var locationLookUp = CLGeocoder();
    
    var currentLocation = CLLocation();
    
    var homeLocationSelected = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    var workLocationSelected = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0);
    
    var settings = Settings();
    
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
        
        self.homeInput.delegate = self ;
        self.workInput.delegate = self ;
        //self.rangeInput.delegate = self ;

        self.homeSuggestions.delegate = self ;
        self.workSuggestions.delegate = self ;
        
        self.homeSuggestions.dataSource = self ;
        self.workSuggestions.dataSource = self ;
        
        self.homeSuggestions.hidden = true;
        self.workSuggestions.hidden = true;
        
        self.initTextFields() ;
        
    }
    
    func initTextFields()
    {
        self.homeInput.text = self.settings.homeAddress ;
        self.workInput.text = self.settings.workAddress ;
        //self.rangeInput.text = String(self.settings.range);

    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any rehomes that can be recreated.
    }
    
    
    //----------------UITableView datasource methods ----------------------------------------------------//
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if tableView == homeSuggestions
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("homeSuggestionListCell") ;
            var address = "";
            if self.homeSuggestionsArray[indexPath.row].thoroughfare != nil
            {
                address += self.homeSuggestionsArray[indexPath.row].thoroughfare! ;
                address += ", ";
            }
            if self.homeSuggestionsArray[indexPath.row].subThoroughfare != nil
            {
                address += self.homeSuggestionsArray[indexPath.row].subThoroughfare! ;
                address += ", ";
            }
            if self.homeSuggestionsArray[indexPath.row].locality != nil
            {
                address += self.homeSuggestionsArray[indexPath.row].locality! ;
                address += ", " ;
            }
            if self.homeSuggestionsArray[indexPath.row].subLocality != nil
            {
                address += self.homeSuggestionsArray[indexPath.row].subLocality! ;
                address += ", ";
            }
            if self.homeSuggestionsArray[indexPath.row].administrativeArea != nil
            {
                address += self.homeSuggestionsArray[indexPath.row].administrativeArea! ;
                address += ", " ;
            }
            address += self.homeSuggestionsArray[indexPath.row].country! ;
            
            cell!.textLabel?.text = address ;
            
            return cell! ;
        }
        else if tableView == workSuggestions
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("workSuggestionListCell") ;
            
            var address = "";
            if self.workSuggestionsArray[indexPath.row].thoroughfare != nil
            {
                address += self.workSuggestionsArray[indexPath.row].thoroughfare! ;
                address += ", ";
            }
            if self.workSuggestionsArray[indexPath.row].subThoroughfare != nil
            {
                address += self.workSuggestionsArray[indexPath.row].subThoroughfare! ;
                address += ", ";
            }
            if self.workSuggestionsArray[indexPath.row].locality != nil
            {
                address += self.workSuggestionsArray[indexPath.row].locality! ;
                address += ", " ;
            }
            if self.workSuggestionsArray[indexPath.row].subLocality != nil
            {
                address += self.workSuggestionsArray[indexPath.row].subLocality! ;
                address += ", ";
            }
            address += self.workSuggestionsArray[indexPath.row].administrativeArea! ;
            address += ", " ;
            address += self.workSuggestionsArray[indexPath.row].country! ;
            
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
        if(tableView == homeSuggestions)
        {
            //limit suggestions to only 4 addresses
            if homeSuggestionsArray.count > 7
            {
                return 7 ;
            }
            else
            {
                return homeSuggestionsArray.count ;
            }
        }
            
        else if (tableView == workSuggestions)
        {
            if workSuggestionsArray.count > 7
            {
                return 7;
            }
            else
            {
                return workSuggestionsArray.count ;
            }
        }
        return 0;
    }
    //-------------End of UITableView datasource methods ------------------------------------------------//
    
    
    //-------------UITableView delegate methods --------------------------------------------------------//
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if(tableView == homeSuggestions)
        {
            print(indexPath.row);
            self.homeLocationSelected.latitude = self.homeSuggestionsArray[indexPath.row].location!.coordinate.latitude ;
            self.homeLocationSelected.longitude = self.homeSuggestionsArray[indexPath.row].location!.coordinate.longitude ;
            self.homeInput.text = self.tableView(tableView, cellForRowAtIndexPath: indexPath).textLabel!.text;
            self.homeSuggestions.hidden = true ;
        }
        else if (tableView == workSuggestions)
        {
            self.workLocationSelected.latitude = self.workSuggestionsArray[indexPath.row].location!.coordinate.latitude ;
            self.workLocationSelected.longitude = self.workSuggestionsArray[indexPath.row].location!.coordinate.longitude ;
            self.workInput.text = self.tableView(tableView, cellForRowAtIndexPath: indexPath).textLabel!.text;
            self.workSuggestions.hidden = true ;
        }
        
    }
    //----------------End of UITableView delegate methods -----------------------------------------------//
    
    
    
    
    
    //------------UITextField delegate methods ------------------------------------------------------------//
    /*
    @IBAction func rangeInputBeginEditing(sender: AnyObject)
    {
        //self.rangeInput.text = "" ;
    }
    */
    //@IBAction func homeInputSelected(sender: AnyObject)
    //{
    //    self.homeInput.text = "" ;
    //}
    
    //@IBAction func worInputSelected(sender: AnyObject)
    //{
    //    self.workInput.text = "" ;
   // }
    @IBAction func homeInputSelected(sender: UITextField)
    {
        self.homeInput.text = "" ;
    }

    @IBAction func workInputSelected(sender: AnyObject)
    {
        self.workInput.text = "" ;
    }
    @IBAction func homeTextChanged(sender: UITextField)
    {
        if homeInput.text?.characters.count > 5
        {
            self.locationLookUp.geocodeAddressString(homeInput.text!, completionHandler: { (placemarks:[CLPlacemark]?, error: NSError?) -> Void in
                
                if error != nil{
                    
                    //handler error
                }
                else
                {
                    self.homeSuggestionsArray.removeAll();
                    
                    self.homeSuggestionsArray =  placemarks! ;
                    
                    self.homeSuggestions.hidden = false;
                    
                    self.homeSuggestions.reloadData();
                }
            });
        }
        else
        {
            self.homeSuggestionsArray.removeAll();
            
            self.homeSuggestions.hidden = true ;
        }
    }
    
    @IBAction func workTextChanged(sender: UITextField)
    {
        if workInput.text?.characters.count > 5
        {
            self.locationLookUp.geocodeAddressString(workInput.text!, completionHandler: { (placemarks:[CLPlacemark]?, error: NSError?) -> Void in
                
                if error != nil{
                    
                    //handler error
                }
                else
                {
                    self.workSuggestionsArray.removeAll();
                    
                    self.workSuggestionsArray =  placemarks! ;
                    
                    self.workSuggestions.hidden = false;
                    
                    self.workSuggestions.reloadData();
                }
            });
        }
        else
        {
            self.workSuggestionsArray.removeAll();
            
            self.workSuggestions.hidden = true ;
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        if textField == homeInput
        {
            self.homeSuggestions.hidden = true;
        }
        else if textField == workInput
        {
            self.workSuggestions.hidden = true;
        }
        textField.resignFirstResponder() ;
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        return true;
    }
    //------------End of UITextField delegate methods --------------------------------//
    


    @IBAction func SaveSettings(sender: AnyObject)
    {
        
        let saveResult = self.settings.saveSettings(self.homeLocationSelected,
                                                    workLocation: self.workLocationSelected,
                                                    homeAddress: self.homeInput.text!,
                                                    workAddress: self.workInput.text!
                                                    /*range: self.rangeInput.text!*/)
        
        if(saveResult)
        {
            let alertController = UIAlertController(title: "Settings", message: "Saved !!", preferredStyle: UIAlertControllerStyle.Alert) ;
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)) ;
            
            self.presentViewController(alertController, animated: true, completion: nil) ;
            
        }
        else
        {
            let alertController = UIAlertController(title: "Settings", message: "Couldn't save !!", preferredStyle: UIAlertControllerStyle.Alert) ;
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil)) ;
            
            self.presentViewController(alertController, animated: true, completion: nil) ;
        }
    }
}