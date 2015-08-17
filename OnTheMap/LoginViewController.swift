//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by George McMullen on 7/8/15.
//  Copyright (c) 2015 George McMullen. All rights reserved.

import UIKit

class LoginViewController: ControllerHelper, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    
    var appDelegate: AppDelegate!
    
    // Enum to hold the login button states
    enum ButtonLabel: String {
        case Login = "Login"
        case Authenicating = "Authenticating..."
        case Success = "Success!"
        // Return the enum string value
        var description: String {
            return self.rawValue
        }
    }
    
    // viewDidLoad
    override func viewDidLoad() {
        // Call parent
        super.viewDidLoad()
        // Store the application delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    // viewWillAppear
    override func viewWillAppear(animated: Bool) {
        // Call parent
        super.viewWillAppear(animated)
        // Setup keyboard notifications
        subscribeToKeyboardNotifications()
        // Do initial screen setup
        uiSetup()
    }
    
    // Unsubscribe for notifications
    override func viewWillDisappear(animated: Bool) {
        // Call parent
        super.viewWillDisappear(animated)
        // Unsubscribe from keyboard notificaitons
        unsubscribeFromKeyboardNotifications()
    }
    
    // User pressed the login button
    @IBAction func loginButtonTouch(sender: AnyObject) {
        // Lock the UI to prevent user from pressing the login button multiple times
        lockUI(true)
        // Create or open the UdacityClient singleton object and call the authentication method
        UdacityClient.sharedInstance().authenticateWithViewController(usernameTextField.text!, password: passwordTextField.text!) { (success, errorString) in
            // Unlock the UI
            self.lockUI(false)
            // If we didn't succeed, then display an error
            if !success {
                // Failure:  Display the error message returned from the authentication routine
                dispatch_async(dispatch_get_main_queue(), {
                    self.loginButton.setTitle(ButtonLabel.Login.rawValue, forState: .Normal)
                    self.showAlert("Login Error", message: errorString!)
                })
                return
            }
            // Complete the login process
            self.completeLogin()
        }
    }
    
    // After a successful login, change the view controller to the main view
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.loginButton.setTitle(ButtonLabel.Success.rawValue, forState: .Normal)
            })
        // Create/open the parse client object and get the student locations
        ParseClient.sharedInstance().getStudentLocation() { (success, errorString) in
            if !success {
                // Failure:  Display the error message returned from the authentication routine
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert("Data Read Error", message: errorString!)
                })
                return
            }
        }
        // Create a new controller to our main tab bar controller
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // Generic UI Setup
    func uiSetup() {
        // Set the text field delegates to us
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.text = ""
        loginButton.setTitle(ButtonLabel.Login.rawValue, forState: .Normal)
    }
    
    // Lock or unlock the UI to allow/prevent user editing
    func lockUI(lock: Bool)->Void {
        // Lock/Unlock the UI immediately
        dispatch_async(dispatch_get_main_queue(), {
            self.usernameTextField.enabled = !lock
            self.passwordTextField.enabled = !lock
            self.loginButton.userInteractionEnabled = !lock
            self.loginButton.setTitle(ButtonLabel.Authenicating.rawValue, forState: .Normal)
        })
    }

    // Manage notifications from Keyboard
    func subscribeToKeyboardNotifications() {
        // Intercept and redirct the keyboard will show message
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:" , name: UIKeyboardWillShowNotification, object: nil)
        // Intercetp and redirect the keyboard will hid message
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:" , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Unsubscribe from keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        // Restore the keyboard will show message to original observer
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        // Restore the keyboard will hide message to the original observer
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Capture if a user touches outside the text area
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        // Close the keyboard when a touch happens outside the control
        view.endEditing(true)
    }
    
    // Method to handle when the keyboard is displayed
    func keyboardWillShow(notification: NSNotification) {
        //NOTE:  The keyboard can grow if the user switches to emotes
        // Always reset the view back to 0 before we raise it.  If we are already raised
        // and the user selects emotes, then we will raise it twice if we don't reset
        view.frame.origin.y = 0  // Reset the frame to 0 before we raise
        // Scroll the view frame up by the size of the keyboard
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    // Method to handle when the keyboard is hidden
    func keyboardWillHide(notification: NSNotification) {
        // Return the screen to the starting position (0)
        view.frame.origin.y = 0
    }
    
    // Calculate the current keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        // Calculate the height of the keyboard so we can scroll the screen if needed
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}
