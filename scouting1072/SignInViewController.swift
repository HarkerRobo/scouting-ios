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
