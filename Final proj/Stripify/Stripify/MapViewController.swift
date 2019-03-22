//
//  MapViewController.swift
//  Stripify
//
//  Created by Suyog Bobhate on 14/04/18.
//  Copyright © 2018 CIS 195 University of Pennsylvania. All rights reserved.
//



import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, CLLocationManagerDelegate, FirebaseManagerDelegate, MKMapViewDelegate {
    
    func didUpdateLocations() {
        if let location = firebaseManager?.currLoc {
            let userLoc = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            annotateMap(userLocation: userLoc)
        }
    }
    
    
    var firebaseManager: FirebaseManager?
    let manager = CLLocationManager()
    let radius = 16090.00  // 10 miles
    // Unwind vars
    var term: String?
    // Map
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Music Near Me"
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        map.delegate = self
        
        firebaseManager?.delegate = self
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: myLocation , span: span)
        map.setRegion(region, animated: true)
        map.isZoomEnabled = true
        // annotate
        let userLoc = CLLocation(latitude: myLocation.latitude, longitude: myLocation.longitude)
        firebaseManager?.currLoc = userLoc
        annotateMap(userLocation: userLoc)
        self.map.showsUserLocation = true
    }
    
    
    // Mark - Core Location Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        
    }
    
    
    // Mark - Map Delegate Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var annotationView : MKAnnotationView?
        if #available(iOS 11.0, *) {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "place")
        } else {
            // Fallback on earlier versions
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "place")
        }
        if annotation is CustomAnnotation {
            annotationView!.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            button.addTarget(annotationView!, action: #selector(didSelectCalloutButton), for: .touchDown)
            annotationView!.rightCalloutAccessoryView = button
        }
        
        return annotationView
    }
    
    @objc func didSelectCalloutButton (view: MKAnnotationView) {
        if view.annotation is MKUserLocation  {
            // do nothing
        } else {
            if let search = view.annotation?.title {
                print ("selected annotation")
                term = search
                performSegue(withIdentifier: "unwindToSearch", sender: Any?.self)
            }
        }
       
    }
    // If annotation was selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation  {
            // do nothing
        } else {
            if let search = view.annotation?.title {
                print ("selected annotation")
                term = search
                performSegue(withIdentifier: "unwindToSearch", sender: Any?.self)
            }
        }
    }
    
    // Mark - private helper methods
    private func annotateMap(userLocation: CLLocation) {
        
        // Add Pin Annotations of songs
        if let locations = firebaseManager?.locations {
            for loc in locations {
                // check location is within mile radius
                let isValid = loc.Location.distance(from: userLocation) < radius
                let annotation = CustomAnnotation(title: loc.SongName, coordinate: CLLocationCoordinate2DMake(loc.Location.coordinate.latitude, loc.Location.coordinate.longitude), isValid: isValid, subtitle: nil)
                map.addAnnotation(annotation)
            }
        }
        
    }
    
}
