//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Peter Schwartz on 11/26/21.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
        
    @IBOutlet weak var signUpTextView: UITextView!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.text = ""
        passwordTextField.text = ""
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.tintColor = UIColor.white
        loginButton.layer.borderColor = UIColor.clear.cgColor
        
        setupSignUpButton()
    }

    @IBAction func login(_ sender: Any) {
        setLoggingIn(true)
        MapClient.login(email: self.emailTextField.text ?? "",
                        password: self.passwordTextField.text ?? "",
                        completion: handleLoginResponse(sessionResponse:error:))
    }
    
    func handleLoginResponse(sessionResponse: SessionResponse?, error: Error?) {
        DispatchQueue.main.async {
            if let sessionResponse = sessionResponse {
                MapClient.Auth.id = sessionResponse.session.id
                MapClient.Auth.expiration = sessionResponse.session.expiration
                MapClient.Auth.userId = sessionResponse.account.key
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
            } else {
                self.showLoginFailure(message: error?.localizedDescription ?? "")
            }
            self.setLoggingIn(false)
        }
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        signUpTextView.isSelectable = !loggingIn
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    func setupSignUpButton() {
        let signUpAttrString = NSMutableAttributedString(string: "Don't have an account? Sign Up")
        let signUpUrl = "https://auth.udacity.com/sign-up?next=https://classroom.udacity.com"
        let signUpHyperlinkText = "Sign Up"
        let linkRange = signUpAttrString.mutableString.range(of: signUpHyperlinkText)
        signUpAttrString.addAttribute(NSAttributedString.Key.link, value: signUpUrl, range: linkRange)
        signUpTextView.attributedText = signUpAttrString
        signUpTextView.delegate = self
        signUpTextView.textAlignment = .center
        self.signUpTextView.linkTextAttributes = [
            .foregroundColor: UIColor.blue
        ]
    }
    
}
