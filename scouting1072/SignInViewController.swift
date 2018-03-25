//
//  SignInViewController.swift
//  scouting1072
//
//  Created by Aydin Tiritoglu on 1/25/18.
//  Copyright © 2018 Aydin Tiritoglu. All rights reserved.
//

import UIKit
import Google
import GoogleSignIn

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let session = appDelegate.session
let hostname = appDelegate.hostname

var shouldBeSignedIn = false

let normalDevices = ["iPhone7,2", "iPhone7,1", "iPhone8,1", "iPhone8,2", "iPhone9,1", "iPhone9,3", "iPhone9,2", "iPhone9,4", "iPhone10,1", "iPhone10,4", "iPhone10,2", "iPhone10,5", "iPhone10,3", "iPhone10,6"]
let smallDevices = ["iPhone5,1", "iPhone5,2", "iPhone5,3", "iPhone5,4", "iPhone6,1", "iPhone6,2", "iPhone8,3", "iPhone8,4"]

public extension Int {
    var toString: String { return "\(self)" }
}

public extension UIDevice {
    var isSupported: Bool {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        let supportedDevices = normalDevices + smallDevices
        var returnValue = false
        if supportedDevices.contains(identifier) {
            returnValue = true
        } else if identifier == "i386" || identifier == "x86_64" {
            if let dir = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                for device in supportedDevices {
                    if dir.contains(device) {
                        returnValue = true
                        break
                    } else {
                        returnValue = false
                    }
                }
            }
        } else {
            returnValue = false
        }
        return returnValue
    }
    var isSmall: Bool {
        var small = false
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        if smallDevices.contains(identifier) {
            small = true
        } else if identifier == "i386" || identifier == "x86_64" {
            if let dir = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                if smallDevices.contains(dir) {
                    small = true
                } else {
                    small = false
                }
            }
        } else {
            small = false
        }
        return small
    }
}

public enum RequestType: CustomStringConvertible {
    case delete
    case post
    case get
    case none
    
    public var description: String {
        switch self {
            case .delete: return "DELETE"
            case .post: return "POST"
            case .get: return "GET"
            default: return "WTF YOU DOING?"
        }
    }
}

class SignInViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var responseCode: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBAction public func signInHauth() {
        let url = URL(string: hostname + "/member/signin/hauth/mobile")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            let loginLink = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            UIApplication.shared.open(URL(string : loginLink! as String)!, options: [:], completionHandler: { (status) in
                // do nothing
            })
        }
        
        task.resume()
    }
    
    public func labelCheck() {
        
            label.text? = "You are signed in!"
            inSession = true
        
    }
    
    var inSession = false
    var httpResponse : HTTPURLResponse? = nil
    var task : URLSessionDataTask? = nil
    var loggedIn = false
    var fromSelf = false
    
    public func performRequest(requestType: RequestType) {
        if let _ = GIDSignIn.sharedInstance().currentUser?.profile.email {
            
        } else {
            if shouldBeSignedIn {
                showAlert(currentVC: self, title: "Sign-in failed!", text: "Please restart the app.")
                activityIndicator.isHidden = true
            }
        }
    }
    
    @objc func signIn() {
        if !justSignedOut {
            print("\n\(String(describing: "PLACEHOLDER user?.profile.email"))\n")
            self.fromSelf = true
                self.loggedIn = true
            self.performRequest(requestType: .post)
            shouldBeSignedIn = true
            justSignedOut = false
            
            self.labelCheck()
            self.performSegue(withIdentifier: "SignInToInterSegue", sender: self)
        } else {
            loggedIn = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        responseCode.isHidden = true
        activityIndicator.isHidden = true
        if !UIDevice.current.isSupported {
//            signInButton.isHidden = true
            label.isHidden = true
        }
        shouldBeSignedIn = false
        NotificationCenter.default.addObserver(self, selector: #selector(signIn), name: NSNotification.Name("userSignedIn"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
