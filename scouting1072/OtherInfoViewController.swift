//
//  OtherInfoViewController.swift
//  scouting1072
//
//  Created by Aydin Tiritoglu on 2/19/18.
//  Copyright © 2018 Aydin Tiritoglu. All rights reserved.
//

class OtherInfoViewController: UIViewController {
    var dataString = String()
    @IBOutlet weak var rampType: UISegmentedControl!
    @IBOutlet weak var rampUsed: UISegmentedControl!
    @IBOutlet weak var onPlatform: UISegmentedControl!
    @IBOutlet weak var lineCrossed: UISegmentedControl!
    @IBAction func finish(_ sender: Any) {
        dataString = """
        {
          "headers": {
            "email": "\(GIDSignIn.sharedInstance().currentUser.profile.email)",
            "rank": \(sergeant ? 10 : 0),
            "blue": \(scoutingUserInfo.scouting.blue),
            "team": \(scoutingUserInfo.scouting.team),
            "round": \(scoutingUserInfo.scouting.round),
            "tournament_id": "\(scoutingUserInfo.tournament.id)",
          },
          "data": {
            "start_position": \(startingPosition),
            "crossed_line": \(lineCrossed.isEnabledForSegment(at: 1)),
            "end_platform": \(onPlatform.isEnabledForSegment(at: 1)),
            "lift": \(rampType.selectedSegmentIndex),
            "auton-actions": [
        """
        for element in sergeant ? autonControlTimes : autonPresses {
            let stringToAppend = "{\"timestamp\": \(element.key), \"action\": \(element.value)},"
            dataString.append(stringToAppend)
        }
        dataString.removeLast()
        dataString.append("],\n\"teleop-actions\": [\n")
        for element in sergeant ? teleOpControlTimes : teleOpPresses {
            let stringToAppend = "{\"timestamp\": \(element.key), \"action\": \(element.value)},"
            dataString.append(stringToAppend)
        }
        dataString.removeLast()
        dataString.append("]\n}\n}")
        print(dataString)
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
            request.httpBody = dataString.data(using: .utf8)
            dispatchGroup.enter()
            task = session.dataTask(with: request) { data, response, error in
                let httpStatus = response as? HTTPURLResponse
                self.httpResponse = httpStatus
                print(httpStatus?.statusCode as Any)
                dispatchGroup.leave()
            }
            task?.resume()
            dispatchGroup.notify(queue: .main) {
                if self.httpResponse?.statusCode == 200 {
                    print("Data sent successfully")
                    self.performSegue(withIdentifier: "OtherToInterSegue", sender: self)
                } else {
                    print("Error received when trying to upload data")
                }
            }
            print(user?.authentication.idToken as Any)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .default
        UIApplication.shared.isStatusBarHidden = false
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
