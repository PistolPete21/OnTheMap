//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Peter Schwartz on 11/26/21.
//

import UIKit
import CoreLocation
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate {

    lazy var geocoder = CLGeocoder()
    var mapSpot = MKPointAnnotation()
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var findButton: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBAction func launchDetail(_ sender: Any) {
        getGeoString()
    }
    
    var studentData = StudentInformation(
        createdAt: "",
        firstName: "",
        lastName: "",
        latitude: 0.0,
        longitude: 0.0,
        mapString: "",
        mediaURL: "",
        objectId: "",
        uniqueKey: MapClient.Auth.userId,
        updatedAt: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.title = "Add Location"
        
        findButton.layer.cornerRadius = 5
        findButton.layer.borderWidth = 1
        findButton.tintColor = UIColor.white
        findButton.layer.borderColor = UIColor.clear.cgColor
        
        getUserData()
        // Do any additional setup after loading the view.
    }
    
    @objc func cancelTapped(){
        loadingIndicator.stopAnimating()
        dismiss(animated: true, completion: nil)
    }
    
    private func getUserData() {
        MapClient.getUserData { user, error in
            DispatchQueue.main.async {
                if let user = user {
                    self.studentData.firstName = user.firstName
                    self.studentData.lastName = user.lastName
                } else {
                    self.showError(message: error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    private func getGeoString() {
        setForegroundBusy(true)

        studentData.mapString = locationTextField.text ?? ""
        studentData.mediaURL = linkTextField.text ?? ""
        
        geocoder.geocodeAddressString(studentData.mapString!) { placemark, error in
            if let placemark = placemark {
                var location: CLLocation?
                location = placemark.first?.location
                
                if let location = location {
                    self.studentData.latitude = location.coordinate.latitude
                    self.studentData.longitude = location.coordinate.longitude
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location.coordinate
                    self.mapSpot = annotation
                    
                    if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "showAddLocationDetail") as? AddLocationDetailController {
                        viewController.studentData = self.studentData
                        viewController.mapSpot = self.mapSpot
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                } else {
                    self.showError(message: error?.localizedDescription ?? "")
                }
                self.setForegroundBusy(false)
            } else {
                self.setForegroundBusy(false)
                self.showError(message: error?.localizedDescription ?? "")
            }
        }
    }
    
    func setForegroundBusy(_ busy: Bool) {
        if busy {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Fetching User Data Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }

}
