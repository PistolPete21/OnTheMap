//
//  File.swift
//  OnTheMap
//
//  Created by Peter Schwartz on 11/27/21.
//

import UIKit
import MapKit

class AddLocationDetailController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var studentData: StudentInformation?
    var mapSpot = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        finishButton.layer.cornerRadius = 5
        finishButton.layer.borderWidth = 1
        finishButton.tintColor = UIColor.white
        finishButton.layer.borderColor = UIColor.clear.cgColor
                
        loadUpMap()
    }
    
    @IBAction func finishTapped(_ sender: Any) {
        if (storyboard?.instantiateViewController(withIdentifier: "mainTabBar") as? UITabBarController) != nil {
            postStudentData()
        }
    }
    
    func postStudentData() {
        if let studentData = studentData {
            MapClient.postStudentLocation(studentInformation: studentData) { student, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.showError(message: error.localizedDescription ?? "")
                    } else {
                        self.performSegue(withIdentifier: "tableViewController", sender: self)
                    }
                }
            }
        }
    }
    
    func loadUpMap () {
        mapView.delegate = self
        DispatchQueue.main.async {
            self.mapView.addAnnotation(self.mapSpot)
            
            let latitude:CLLocationDegrees = self.studentData?.latitude ?? 0
            let longitude:CLLocationDegrees = self.studentData?.longitude ?? 0
            
            let latitudeDelta:CLLocationDegrees = 0.05
            let longitudeDelta:CLLocationDegrees = 0.05
            
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            let location = CLLocationCoordinate2DMake(latitude, longitude)
            let region = MKCoordinateRegion(center: location, span: span)
            self.mapView.setRegion(region, animated: false)
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
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
