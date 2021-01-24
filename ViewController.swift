//
//  ViewController.swift
//  Map Demo
//
//  Created by Macbook on 2021-01-21.
//

import UIKit
import MapKit

class ViewController: UIViewController , CLLocationManagerDelegate
{
    @IBOutlet weak var map : MKMapView!
    @IBOutlet weak var directionBtn: UIButton!
    
    //destination variable
    var destination : CLLocationCoordinate2D!
    //make it implicitly unwrapped optional, when not double tapped it is not in use
    
    //create a location manager
    var locationManager = CLLocationManager()
    
    
    // create a places array
    
    let places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        //to enable/disable  the zoom programmatically
        map.isZoomEnabled = false
        
        //to show location of the user programmaticall after unchecking the user location in the storyboard
        map.showsUserLocation = true
        
        directionBtn.isHidden = true
        
        //to get user location
        //we assign the delegate property of the location manager to be this class
        locationManager.delegate = self
        
        //define accuracy of the location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //request to access user location
        locationManager.requestWhenInUseAuthorization()
        
        //to start pdating the location
        locationManager.startUpdatingLocation()
        
        //first step is to define latitude and longitude of the place we want to show marker of
        
        let latitude : CLLocationDegrees = 43.64
        let longitude : CLLocationDegrees = -79.38
        
        //second step is to display marker on the map
        displayLocation(latitude: latitude, longitude: longitude, title: "Toronto City", subtitle: "You are here")
        
    let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(addLongPressAnnotattion))
     map.addGestureRecognizer(uilpgr)
        //uilpgr means ui long press
        
        // add double tap
        addDoubleTap()
        
        // giving the delegate of MKMapViewDelegate to this class
        map.delegate = self
        
        //create annotation for the places I have
        //addAnnotationsForPlaces()
        
        //add polyline - direct line between two points
        //addPolyline()
        
        //add polygon
        //addPolygon()
        
    }
    //MARK: - to draw route between two places
    
    @IBAction func drawRoute(_ sender: Any)
    {
        //remove everything thee is on map
        map.removeOverlays(map.overlays)
        
        let sourcePlacemark = MKPlacemark(coordinate: locationManager.location!.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        //request a direction, create instance of request
        let directionRequest = MKDirections.Request()
        
        //assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        
        //type of transportation u want, example walking etc
        directionRequest.transportType = .automobile
        
        // calculate the direction, paasing the direction request to instatiate this class
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            
            //if there is error simply return else create route for my purpose
            let route = directionResponse.routes[0]
            
            // drawing the polyline
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            
            //define the bounding map rectangle
            let rect = route.polyline.boundingMapRect
            
            //define visibilty of mapRect , means ow will it appear on screen , 100 is padding from all sides
            self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            
            //define region in which the route comes, on zooming that much area will be visible only
           // self.map.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
    }
    //MARK: - didUpdateLocation method
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //while in a freeway drive the marker keeps overlapping so to remove them
        removePin()
        
        // to see how many locations come in the array to get the most precise location
       // print(locations.count)
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "You are here", subtitle: "")
    }
    
    //MARK: - add annotations for the places
    
    func addAnnotationsForPlaces()
    {
        map.addAnnotations(places)
        
        let overlays = places.map {MKCircle(center: $0.coordinate, radius: 2000)}
        // add this overlay on the map
        map.addOverlays(overlays)
    }
    
    //MARK: - polyline  meyhod
    func addPolyline()
    {
        let coordinates = places.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polyline)
    }
    
    //MARK: - polygon  meyhod
    func addPolygon()
    {
        let coordinates = places.map { $0.coordinate }
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polygon)
    }
    
    //MARK: - double tap function
    func addDoubleTap()
    {
        let doubleTap = UITapGestureRecognizer(target: self , action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)
    }
    @objc func dropPin(sender: UITapGestureRecognizer)
    {
        removePin()
        
        //add annotation
        let touchpoint = sender.location(in: map)
        let coordinate = map.convert(touchpoint, toCoordinateFrom: map)
        
        let annotation = MKPointAnnotation()
        annotation.title = "My destination"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
        //instatiate the destination with the corresponding coordinate on double tap
        destination = coordinate
        //after the destination is choosen,pin is dropped , button should be visible
        directionBtn.isHidden = false
    }
    
    //MARK: - long press gesture recognizer for the annotation
    
    @objc func addLongPressAnnotattion( gestureRecognizer: UIGestureRecognizer)
    {
        let touchPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
    
        //add annotation for the coordinate
        
        let annotation = MKPointAnnotation()
        annotation.title = "My favorite"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
    
    }
    
    //MARK: - remove pin fron the map
    
    func removePin()
    {
        for annotation in map.annotations
        {
            map.removeAnnotation(annotation)
        }
    }
    
   //MARK: - display user location method
    
    func displayLocation (latitude: CLLocationDegrees,
                          longitude: CLLocationDegrees,
                          title: String,
                          subtitle:String)
    {
        // 2nd step - define span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan (latitudeDelta: latitude, longitudeDelta: lngDelta)
        
        //3rd step is to define the location
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        //4th step is to define the region
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        //5th step is to  set the region for the map
        
        map.setRegion(region, animated: true)
        
        //6th step is to add annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
    }

}
//shows how we can show annotations
extension ViewController : MKMapViewDelegate
{
    //MARK: - view for annotation method
    
    func mapView(_ mapView: MKMapView, viewFor annotaion : MKAnnotation) -> MKAnnotationView?
    {
        //to show the blue circle around the user
        if annotaion is MKUserLocation
        {
            return nil
        }
        //write anything to customise your pin
        //let pinAnnotation = MKPinAnnotationView(annotation: annotaion, reuseIdentifier: "droppablePin")
       // pinAnnotation.animatesDrop = true
       // pinAnnotation.pinTintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        
        //add custom annotation
        let pinAnnotation = map.dequeueReusableAnnotationView(withIdentifier: "droppablePin") ?? MKPinAnnotationView()
        pinAnnotation.image = UIImage(named: "ic_place_2x")
        pinAnnotation.canShowCallout = true
        pinAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return pinAnnotation
        
        //custom marker
        let annotationView  = MKMarkerAnnotationView(annotation: annotaion, reuseIdentifier: "MyMarker")
        annotationView.markerTintColor = UIColor.blue
        return annotationView
    }
    
    //MARK: - callout accessory control tapped
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "Your Location" , message: "Nice Place to visit", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - render for overlay func
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle
        {
            let rendrer = MKCircleRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
            // 50 percent means greyush color
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        }
        else if overlay is MKPolyline
        {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 3
            return rendrer
        }
        else if overlay is MKPolygon
        {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.6)
            rendrer.strokeColor = UIColor.yellow
            rendrer.lineWidth = 4
            return rendrer
        }
        return MKOverlayRenderer()
    }
}
