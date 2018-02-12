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

public extension Int {
    var toString: String { return "\(self)" }
}

public enum RequestType : CustomStringConvertible {
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
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var responseCode: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBAction func signOut(_ sender: Any) {
        performRequest(requestType: .delete)
        GIDSignIn.sharedInstance().signOut()
        loggedIn = false
    }
    
    public func labelCheck() {
        if let userEmail = GIDSignIn.sharedInstance().currentUser?.profile.email {
            label.text? = userEmail
            signOutButton.isHidden = false
            responseCode.isHidden = false
        } else {
            label.text = "Welcome to Scouting!"
            inSession = false
            signOutButton.isHidden = true
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
    
    public func performRequest(requestType: RequestType) {
        if let _ = GIDSignIn.sharedInstance().currentUser?.profile.email {
            let dispatchGroup = DispatchGroup()
            if requestType != RequestType.none {
                let url = URL(string: "http://robotics.harker.org/member/token")!
                var request = URLRequest(url: url)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpMethod = requestType.description
                if requestType == .post && loggedIn {
                    let restString = "idtoken=\((user?.authentication.idToken)!)"
                    request.httpBody = restString.data(using: .utf8)
                }
                dispatchGroup.enter()
                task = URLSession(configuration: .default).dataTask(with: request) { data, response, error in
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
                default: task?.resume()
                }
            }
            dispatchGroup.notify(queue: .main) {
                self.labelCheck()
                self.performSegue(withIdentifier: "SignInToInterSegue", sender: self)
            }
            print(user?.authentication.idToken as Any)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().uiDelegate = self
        signOutButton.isHidden = true
        responseCode.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        print("\n\(String(describing: user?.profile.email))\n")
        if let _ = GIDSignIn.sharedInstance().currentUser?.profile {
            loggedIn = true
            performRequest(requestType: .post)
        } else {
            loggedIn = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
