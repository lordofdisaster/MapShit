//
//  ViewController.swift
//  showPlaceOnMap
//
//  Created by Edgar Skobichevskiy on 24/10/2017.
//  Copyright © 2017 Serhii Kyrychenko. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class ViewController: UIViewController , UISearchBarDelegate, CLLocationManagerDelegate {


    @IBOutlet weak var mapView: MKMapView!
    @IBAction func searchButton(_ sender: Any)
    {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //ignoring user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //Activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        //hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
      
        // create the search request
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (responce, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if responce == nil {
                print(error?.localizedDescription ?? "ERROR")
            }
            else {
                // remove annotations
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                // getting data
                let latitude = responce?.boundingRegion.center.latitude
                let longitude = responce?.boundingRegion.center.longitude
                
                // create annotation (pin)
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.mapView.addAnnotation(annotation)
                
                // Zooming an annotations
                let coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpanMake(0.1, 0.1)
                let region = MKCoordinateRegionMake(coordinate, span)
                self.mapView.setRegion(region, animated: true)
            }
        }
        
        
    }

    // CL manager
    
    let manager = CLLocationManager()
    
    
    // delegate function calld every time when user changes locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0] // [0] means the most recent position of our user
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        
        //show user location as a blue dot
        
        self.mapView.showsUserLocation = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // coreLocation Staf
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }


}

