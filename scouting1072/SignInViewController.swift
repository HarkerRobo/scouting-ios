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

var session = URLSession(configuration: .default)
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

class SignInViewController: UIViewController, GIDSignInUIDelegate {
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var responseCode: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    public func labelCheck() {
        if let userEmail = GIDSignIn.sharedInstance().currentUser?.profile.email {
            label.text? = userEmail
            responseCode.isHidden = false
        } else {
            label.text? = "Welcome to Scouting!"
            inSession = false
        }
        if httpResponse?.statusCode == 200 {
            responseCode.text = "Successfully \((GIDSignIn.sharedInstance().currentUser?.profile.email != nil) ? "connected to" : "disconnected from") server (200)"
        } else {
            responseCode.text = "Received unexpected response \(httpResponse!.statusCode))"
        }
    }
    
    var inSession = false
    var httpResponse : HTTPURLResponse? = nil
    var task : URLSessionDataTask? = nil
    var loggedIn = false
    var fromSelf = false
    
    public func performRequest(requestType: RequestType) {
        if let _ = GIDSignIn.sharedInstance().currentUser?.profile.email {
            let dispatchGroup = DispatchGroup()
            let url = URL(string: "http://robotics.harker.org/member/token")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = requestType.description
            if requestType == .post && loggedIn {
                let restString = "idtoken=\((user?.authentication.idToken)!)"
                request.httpBody = restString.data(using: .utf8)
            }
            dispatchGroup.enter()
            task = session.dataTask(with: request) { data, response, error in
                if let httpStatus = response as? HTTPURLResponse {
                    if httpStatus.statusCode != 200 {
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    } else {
                        print(httpStatus.statusCode as Any)
                        self.inSession = true
                    }
                    self.httpResponse = httpStatus
                    if let fields = self.httpResponse?.allHeaderFields as? [String : String] {
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response!.url!)
                        HTTPCookieStorage.shared.setCookies(cookies, for: response!.url!, mainDocumentURL: nil)
                        for cookie in cookies {
                            print(cookie.name)
                        }
                    }
                }
                print(self.httpResponse?.statusCode as Any)
                dispatchGroup.leave()
            }
            switch requestType {
            case .delete:
                task?.cancel()
                task = nil
                inSession = false
            default:
                task?.resume()
                self.activityIndicator.isHidden = false
            }
            dispatchGroup.notify(queue: .main) {
                if self.fromSelf {
                    self.labelCheck()
                    self.performSegue(withIdentifier: "SignInToInterSegue", sender: self)
                }
            }
        } else {
            if shouldBeSignedIn {
                showAlert(currentVC: self, title: "Sign-in failed!", text: "Please restart the app.")
                activityIndicator.isHidden = true
            }
        }
    }
    
    @objc func signIn() {
        if !justSignedOut {
            print("\n\(String(describing: user?.profile.email))\n")
            self.fromSelf = true
            if let _ = GIDSignIn.sharedInstance().currentUser?.profile {
                self.loggedIn = true
            } else {
                self.loggedIn = false
            }
            self.performRequest(requestType: .post)
            shouldBeSignedIn = true
            justSignedOut = false
        } else {
            loggedIn = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().uiDelegate = self
        responseCode.isHidden = true
        activityIndicator.isHidden = true
        if !UIDevice.current.isSupported {
            signInButton.isHidden = true
            label.isHidden = true
        }
        shouldBeSignedIn = false
        NotificationCenter.default.addObserver(self, selector: #selector(signIn), name: NSNotification.Name.userSignedIn, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
