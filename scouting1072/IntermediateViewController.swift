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
var json = Data()

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

class IntermediateViewController: UIViewController {
    @IBOutlet weak var roundNumber: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    var response : HTTPURLResponse? = nil
    var task : URLSessionDataTask? = nil
    
    @IBAction func performGetRequest(_ sender: Any) {
        let dispatchGroup = DispatchGroup()
        let url = URL(string: "https://robotics.harker.org/member/scouting/request/\(roundNumber.text!))")!
        print(url)
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        dispatchGroup.enter()
        task = session.dataTask(with: request) { data, response, error in
            if let httpStatus = response as? HTTPURLResponse {
                self.response = httpStatus
                json = data!
                if httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                } else {
                    print(httpStatus.statusCode as Any)
                }
            }
            dispatchGroup.leave()
        }
        task?.resume()
        dispatchGroup.notify(queue: .main) {
            print(self.response?.statusCode ?? "no response")
            print(String(describing: json))
            print(String(describing: NSData(data: json)))
            let decoder = JSONDecoder()
            if let scoutingInfo = try? decoder.decode(ScoutingInfo.self, from: json) {
                scoutingUserInfo = scoutingInfo
                sergeant = scoutingUserInfo.scouting.rank == 10
                print("User is a \(sergeant ? "seargent" : "private")")
                self.performSegue(withIdentifier: "InterToAutonSegue", sender: self)
            } else {
                print("Failure decoding JSON")
                self.errorLabel.isHidden = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        errorLabel.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
