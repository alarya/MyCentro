//
//  BusDetailsController.swift
//  MyCentro
//
//  Created by Alok Arya on 11/17/15.
//  Copyright © 2015 Alok_Arya. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class BusDetailsController: UIViewController, MKMapViewDelegate,  CLLocationManagerDelegate
{
    var busDetails: PredictionObject ;
    var centroAPI : CentroBusApiCaller;
    var locationManager = CLLocationManager();
    
    @IBOutlet weak var sourceName: UILabel!
    @IBOutlet weak var destName: UILabel!
    @IBOutlet weak var sourceTime: UILabel!
    @IBOutlet weak var destTime: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    convenience init()
    {
        self.init(nibName: nil, bundle: nil);
    }
    //default initializer
    required init(coder aDecoder: NSCoder)
    {
        self.busDetails = PredictionObject();
        self.centroAPI = CentroBusApiCaller();
        super.init(coder: aDecoder)!;
    }
    //designated initializer
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)
    {
        self.busDetails = PredictionObject();
        self.centroAPI = CentroBusApiCaller();
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.locationManager.delegate = self ;
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation();
        
        //Set up view labels
        self.sourceName.text = self.busDetails.sourcestpnm ;
        self.destName.text = self.busDetails.deststpnm ;
        self.sourceTime.text = self.busDetails.sourceprdtm.componentsSeparatedByString(" ").last ;
        self.destTime.text = self.busDetails.destprdtm.componentsSeparatedByString(" ").last ;
        
        //annotate
        let sourcePin = BusStop.init(name: self.busDetails.sourcestpnm,
                                     coordinate: CLLocationCoordinate2D.init(latitude: self.busDetails.sourcelocation.coordinate.latitude,
                                                                            longitude: self.busDetails.sourcelocation.coordinate.longitude),
                                     title: self.busDetails.sourcestpnm,
                                     subtitle: self.busDetails.sourceprdtm) ;
        let destPin = BusStop.init(name: self.busDetails.deststpnm,
                                   coordinate: CLLocationCoordinate2D.init(latitude: self.busDetails.destlocation.coordinate.latitude,
                                                                          longitude: self.busDetails.destlocation.coordinate.longitude),
                                   title: self.busDetails.deststpnm,
                                   subtitle: self.busDetails.destprdtm) ;
        
        self.mapView.delegate = self ;
        
        self.mapView.addAnnotation(sourcePin);
        self.mapView.addAnnotation(destPin);
        self.mapView.selectAnnotation(sourcePin, animated: true);
        self.mapView.showsUserLocation = true ;
    
        
        //intialize map
        self.centerMapOnLocation(self.busDetails.sourcelocation,
                                 regionRadius: self.busDetails.sourcelocation.distanceFromLocation(self.busDetails.destlocation)) ;
        self.centroAPI.stopsBetweenSourceDest(self.busDetails.sourcestpid, destStpId: self.busDetails.deststpid,
                                 route: self.busDetails.rt, routeDir: self.busDetails.rtdir, controller: self) ;
        
        
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //----------------------MKMapView Delegate methods -------------------------------------------------//
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        
        let identifier = "pin" ;
        var view: MKAnnotationView ;
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as MKAnnotationView!
        {
            dequeuedView.annotation = annotation ;
            view = dequeuedView ;
            
        }
        else
        {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier) ;
            view.canShowCallout = true ;
            view.calloutOffset = CGPoint(x: -5, y: 5) ;
        }
        
        if(annotation.title!! == self.busDetails.sourcestpnm || annotation.title!! == self.busDetails.deststpnm)
        {
            view.image = UIImage(named: "busAnnotation.png") ;
        }
        else
        {
            return nil ; 
        }
        
        return view ;
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
    {
        if overlay is MKPolyline
        {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay) ;
            polylineRenderer.strokeColor = UIColor.blueColor() ;
            polylineRenderer.lineWidth = 2 ;
            
            return polylineRenderer ;
        }
        
        return MKOverlayRenderer() ;
    }
    //------------------------End of MKMapView Delegate methods ---------------------------------------//
    
    
    //-----------------Utility methods -----------------------------------------------------------------//
    
    //Initialize map area
    func centerMapOnLocation(location: CLLocation, regionRadius: CLLocationDistance)
    {
        //let regionRadius : CLLocationDistance = 600 ;
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0) ;
        self.mapView.setRegion(coordinateRegion, animated: true);
    }
    
    //draw route defined by stops
    func drawRoute(stops: [Stop])
    {
        var points = [CLLocationCoordinate2D]() ;
        
        points.append(CLLocationCoordinate2D.init(latitude: self.busDetails.sourcelocation.coordinate.latitude,
                                                  longitude: self.busDetails.sourcelocation.coordinate.longitude));
        
        for stop in stops
        {
            points.append(CLLocationCoordinate2D.init(latitude: stop.lat, longitude: stop.lon)) ;
        }
        
        points.append(CLLocationCoordinate2D.init(latitude: self.busDetails.destlocation.coordinate.latitude,
                                                  longitude: self.busDetails.destlocation.coordinate.longitude));
        
        let pointsPointer : UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer(points) ;
        let polyline = MKPolyline.init(coordinates: pointsPointer, count: points.count);
        
        
        
        dispatch_sync(dispatch_get_main_queue(), {
            self.mapView.addOverlay(polyline);
            
            for stop in stops
            {
                let stopAnnotate = BusStop.init(name: stop.stpnm, coordinate: CLLocationCoordinate2D.init(latitude: stop.lat,
                                                longitude: stop.lon), title: stop.stpnm , subtitle: "");
                
                self.mapView.addAnnotation(stopAnnotate);
            }
        });
    }
    

}

/***************************
    Map Annotation Object
****************************/
class BusStop : NSObject, MKAnnotation
{
    let name : String
    let coordinate : CLLocationCoordinate2D
    let title : String?
    let subtitle : String?
    
    init(name: String, coordinate: CLLocationCoordinate2D, title: String, subtitle: String)
    {
        self.name = name
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init();
    }
}