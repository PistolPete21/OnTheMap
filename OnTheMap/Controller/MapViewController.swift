//
//  ViewController.swift
//  OnTheMap
//
//  Created by Peter Schwartz on 11/26/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    var mapSpot : [MKPointAnnotation] = []
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getMapData()
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        mapView.removeAnnotations(mapSpot)
        mapSpot.removeAll()
        getMapData()
    }

    @IBAction func addLocationButton(_ sender: Any) {
        performSegue(withIdentifier: "showInfoPosting", sender: nil)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        MapClient.logout(completion: handleLogoutResponse(session:error:))
    }
    
    func handleLogoutResponse(session: Session?, error: Error?) {
        MapClient.logout { session, error in
            DispatchQueue.main.async {
                if let session = session {
                    MapClient.Auth.id = session.id
                    MapClient.Auth.expiration = session.expiration
                    MapClient.Auth.userId = ""
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                } else {
                    self.showError(message: error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinView!.pinTintColor = .blue
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let url = view.annotation?.subtitle! {
                app.open(URL(string: url)!)
            }
        }
    }

    // MARK: - Data
    
    func getMapData() {
        MapClient.getStudentLocations() { data, error in
            DispatchQueue.main.async {
                if let data = data {
                    StudentModel.students = data.results
                    for student in data.results {
                        let lat = CLLocationDegrees(student.latitude ?? 0.0)
                        let long = CLLocationDegrees(student.longitude ?? 0.0)
                        
                        // The lat and long are used to create a CLLocationCoordinates2D instance.
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        let first = student.firstName ?? ""
                        let last = student.lastName ?? ""
                        let mediaURL = student.mediaURL
                        
                        // Here we create the annotation and set its coordiate, title, and subtitle properties
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = first + " " + last
                        annotation.subtitle = mediaURL
                        
                        // Finally we place the annotation in an array of annotations.
                        self.mapSpot.append(annotation)
                    }
                    self.mapView.addAnnotations(self.mapSpot)
                } else {
                    self.showError(message: error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

