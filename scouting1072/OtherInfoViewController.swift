//
//  OtherInfoViewController.swift
//  scouting1072
//
//  Created by Aydin Tiritoglu on 2/19/18.
//  Copyright © 2018 Aydin Tiritoglu. All rights reserved.
//

var manualDict = [String: Any]()
var dataString = String()
var autonActions = [[String: Any]]()
var teleOpActions = [[String: Any]]()
var keyboardAdjusted = false
var lastKeyboardOffset: CGFloat = 0.0

extension String {
    mutating func prepend(_ other: String) {
        self = other + self
    }
}

func printData(_ data: Data) {
    var responseData = String(describing: NSData(data: data))
    var responseString = String()
    responseData.removeLast()
    responseData.removeFirst()
    responseData = responseData.components(separatedBy: .whitespaces).joined()
    let chars = Array(responseData[responseData.startIndex...])
    let _ = stride(from: 0, to: chars.count, by: 2).map() {
        let twoChars = String(chars[$0 ..< min($0 + 2, chars.count)])
        responseString.append(String(describing: UnicodeScalar(Int(twoChars, radix: 16)!)!))
    }
    print(responseString)
}

class OtherInfoViewController: UIViewController {
    var dataDict = Dictionary<String, Dictionary<String, Any>>()
    var json = Data()
    @IBOutlet weak var comments: UITextView!
    @IBOutlet weak var rampType: UISegmentedControl!
    @IBOutlet weak var onPlatform: UISegmentedControl!
    @IBOutlet weak var lineCrossed: UISegmentedControl!
    @IBAction func finish(_ sender: Any) {
         manualDict = ["headers[email]": GIDSignIn.sharedInstance().currentUser.profile.email!, "headers[rank]": sergeant ? 10: 0, "headers[blue]": scoutingUserInfo.scouting.blue, "headers[team]": scoutingUserInfo.scouting.team, "headers[round]": scoutingUserInfo.scouting.round, "headers[tournament_id]": scoutingUserInfo.tournament.id, "data[startPosition]": startingPosition, "data[crossed_line]": lineCrossed.isEnabledForSegment(at: 1), "data[end_platform]": onPlatform.isEnabledForSegment(at: 1), "data[lift]": rampType.selectedSegmentIndex, "data[auton-actions]": [[String: Any]](), "data[teleop-actions]": [[String: Any]]()]
        var counter = 0
        for element in sergeant ? autonControlTimes : autonPresses {
            autonActions.append(["timestamp": "\(element.key)", "action": "\(element.value)"])
            counter += 1
        }
        counter = 0
        for element in sergeant ? teleOpControlTimes : teleOpPresses {
            teleOpActions.append(["timestamp": "\(element.key)", "action": "\(element.value)"])
            counter += 1
        }
        manualDict["data[auton-actions]"] = autonActions
        manualDict["data[teleop-actions]"] = teleOpActions
        dataString = "headers[email]=\(GIDSignIn.sharedInstance().currentUser.profile.email!)&headers[rank]=\(sergeant ? 10 : 0)&headers[blue]=\(scoutingUserInfo.scouting.blue)&headers[team]=\(scoutingUserInfo.scouting.team)&headers[round]=\(scoutingUserInfo.scouting.round)&headers[tournament_id]=\(scoutingUserInfo.tournament.id)&headers[forceUpload]=true&data[start_position]=\(startingPosition)&data[crossed_line]=\(lineCrossed.isEnabledForSegment(at: 1))&data[end_platform]=\(onPlatform.isEnabledForSegment(at: 1))&data[lift]=\(rampType.selectedSegmentIndex)&data[comments]=\(comments.text ?? "")&data[auton-actions]="
        var autonString = String(describing: autonActions)
        autonString.removeFirst()
        autonString.removeLast()
        autonString = autonString.replacingOccurrences(of: "[", with: "{")
        autonString = autonString.replacingOccurrences(of: "]", with: "}")
        autonString.append("]")
        autonString.prepend("[")
        dataString.append(autonString)
        dataString.append("&data[teleop-actions]=")
        var teleOpString = String(describing: teleOpActions)
        teleOpString.removeFirst()
        teleOpString.removeLast()
        teleOpString = teleOpString.replacingOccurrences(of: "[", with: "{")
        teleOpString = teleOpString.replacingOccurrences(of: "]", with: "}")
        teleOpString.append("]")
        teleOpString.prepend("[")
        dataString.append(teleOpString)
        print("\n\n\(dataString)\n\n")
        performRequest(requestType: .post)
    }
    
    var task : URLSessionDataTask? = nil
    var httpResponse : HTTPURLResponse? = nil
    
    public func performRequest(requestType: RequestType) {
        if let _ = GIDSignIn.sharedInstance().currentUser?.profile.email {
            let dispatchGroup = DispatchGroup()
            let url = URL(string: "http://robotics.harker.org/member/scouting/upload")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = requestType.description
            var bodyData = [
                "headers": [
                    "email": "\(GIDSignIn.sharedInstance().currentUser.profile.email!)",
                    "rank": sergeant ? 10 : 0,
                    "blue": "\(scoutingUserInfo.scouting.blue)",
                    "team": scoutingUserInfo.scouting.team,
                    "round": scoutingUserInfo.scouting.round,
                    "tournament_id": "\(scoutingUserInfo.tournament.id)"
                ],
                "data": [
                    "start_position": startingPosition,
                    "crossed_line": lineCrossed.isEnabledForSegment(at: 1),
                    "end_platform": onPlatform.isEnabledForSegment(at: 1),
                    "lift": rampType.selectedSegmentIndex,
                    "auton-actions": [
                    ],
                    "teleop-actions": [
                    ]
                ]
            ]
            bodyData["data"]!["auton-actions"] = autonActions
            bodyData["data"]!["teleop-actions"] = teleOpActions
            // print(bodyData)
            let _ = try? JSONSerialization.data(withJSONObject: bodyData)
            request.httpBody = dataString.data(using: .utf8)!
            dispatchGroup.enter()
            task = session.dataTask(with: request) { data, response, error in
                let httpStatus = response as? HTTPURLResponse
                self.httpResponse = httpStatus
                if let resData = data {
                    printData(resData)
                }
                print(httpStatus!.statusCode)
                dispatchGroup.leave()
            }
            task?.resume()
            dispatchGroup.notify(queue: .main) {
                if self.httpResponse?.statusCode == 200 {
                    print("Data sent successfully")
                    self.performSegue(withIdentifier: "OtherToInterSegue", sender: self)
                } else {
                    print("Error attempting to upload data (\(self.httpResponse!.statusCode))")
                }
                self.task?.cancel()
                self.task = nil
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification)
            view.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            view.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.delegate?.window??.rootViewController = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.comments.delegate = self as? UITextViewDelegate
        appdelegate.shouldRotate = true
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        let borderColor: UIColor? = UIColor(red: 204.0 / 255.0, green: 204.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        comments.layer.borderColor = borderColor?.cgColor
        comments.layer.borderWidth = 1.0
        comments.layer.cornerRadius = 5.0
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
