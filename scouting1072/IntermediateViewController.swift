//
//  IntermediateViewController.swift
//  scouting1072
//
//  Created by Aydin Tiritoglu on 2/1/18.
//  Copyright © 2018 Aydin Tiritoglu. All rights reserved.
//

import UIKit
import Google
import GoogleSignIn

var scoutingUserInfo = ScoutingInfo(tournament: Tournament(year: 0, name: "", id: ""), scouting: Scouting(round: 0, rank: 0, blue: false, team: 0))
var sergeant = false
var jsonInter = Data()
var justSignedOut = false
var keyboardHeight = CGFloat()

struct Tournament: Codable {
    var year: Int
    var name: String
    var id: String
}

struct Scouting: Codable {
    var round: Int
    var rank: Int
    var blue: Bool
    var team: Int
}

struct ScoutingInfo: Codable {
    var tournament: Tournament
    var scouting: Scouting
}

extension Data {
    func toString() -> String {
        return String(data: self, encoding: .utf8)!
    }
}

class IntermediateViewController: UIViewController, UITextFieldDelegate {
    var response : HTTPURLResponse? = nil
    var task : URLSessionDataTask? = nil
    @IBOutlet weak var roundNumber: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func signOut(_ sender: Any) {
        SignInViewController().performRequest(requestType: .delete)
        GIDSignIn.sharedInstance().signOut()
        justSignedOut = true
        session = URLSession(configuration: .default)
        shouldBeSignedIn = false
        performSegue(withIdentifier: "InterToSignIn", sender: self)
    }
    
    @IBAction func performGetRequest(_ sender: Any) {
        print("button pressed")
        let dispatchGroup = DispatchGroup()
        if let _ = Int(roundNumber.text!) {
            if let url = URL(string: "https://robotics.harker.org/member/scouting/request/\(roundNumber.text!))") {
                print(url)
                var request = URLRequest(url: url)
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "GET"
                dispatchGroup.enter()
                task = session.dataTask(with: request) { data, response, error in
                    if let httpStatus = response as? HTTPURLResponse {
                        self.response = httpStatus
                        jsonInter = data!
                        if httpStatus.statusCode != 200 {
                            print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        } else {
                            print(httpStatus.statusCode as Any)
                        }
                    }
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = false
                    }
                    dispatchGroup.leave()
                }
                task?.resume()
                dispatchGroup.notify(queue: .main) {
                    print(self.response?.statusCode ?? "no response")
                    print(String(describing: jsonInter))
                    print(String(describing: NSData(data: jsonInter)))
                    let decoder = JSONDecoder()
                    if let scoutingInfo = try? decoder.decode(ScoutingInfo.self, from: jsonInter) {
                        scoutingUserInfo = scoutingInfo
                        sergeant = scoutingUserInfo.scouting.rank == 10
                        print("User is a \(sergeant ? "sergeant" : "private")")
                        self.activityIndicator.isHidden = true
                        self.performSegue(withIdentifier: "InterToAutonSegue", sender: self)
                    } else {
                        printData(jsonInter)
                        print("Failure decoding JSON")
                        self.errorLabel.isHidden = false
                    }
                }
            } else {
                print("Invalid URL")
                self.errorLabel.isHidden = false
            }
        } else {
            showAlert(currentVC: self, title: "Invalid number", text: "Please enter a number.")
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        errorLabel.isHidden = true
        autonActions = [[String : Any]]()
        teleOpActions = [[String : Any]]()
        autonPresses = [Double : String]()
        teleOpPresses = [Double : String]()
        autonControlTimes = [Double : String]()
        teleOpControlTimes = [Double : String]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.roundNumber.delegate = self
        activityIndicator.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
