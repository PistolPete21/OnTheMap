//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Peter Schwartz on 11/26/21.
//

import UIKit

class TableViewController: UIViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadStudents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        setForegroundBusy(true)
        MapClient.getStudentLocations() { data, error in
            DispatchQueue.main.async {
                if let data = data {
                    StudentModel.students = data.results
                    self.tableView.reloadData()
                    self.setForegroundBusy(false)
                } else {
                    self.showError(message: error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    @IBAction func addStudentInfo(_ sender: Any) {
        performSegue(withIdentifier: "showInfoPosting", sender: nil)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        MapClient.logout(completion: handleLogoutResponse(session:error:))
    }
    
    func loadStudents() {
        MapClient.getStudentLocations() { data, error in
            DispatchQueue.main.async {
                if let data = data {
                    StudentModel.students = data.results
                    self.tableView.reloadData()
                } else {
                    self.showError(message: error?.localizedDescription ?? "")
                }
            }
        }
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
    
    func setForegroundBusy(_ busy: Bool) {
        if busy {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
}

extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapTableViewCell")!
        
        let student = StudentModel.students[indexPath.row]
        
        cell.textLabel?.text = student.firstName! + " " + student.lastName!
        cell.detailTextLabel?.text = student.mediaURL!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mediaURL = StudentModel.students[indexPath.row].mediaURL {
            if let mediaURL = URL(string: mediaURL) {
                UIApplication.shared.open(mediaURL)
            }
        }
    }
    
    func showError(message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
