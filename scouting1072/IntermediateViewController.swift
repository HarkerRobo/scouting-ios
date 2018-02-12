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

var scoutingUserInfo : ScoutingInfo? = nil

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

class IntermediateViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        performSegue(withIdentifier: "InterToAutonSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let json = "{\n\"tournament\": {\n\"year\": 2018,\n\"name\": \"SVR\",\n\"id\": \"59b1\"\n},\n\"scouting\": {\n\"round\": 55,\n\"rank\": 0,\n\"blue\": true,\n\"team\": 1072\n}\n}"
        let decoder = JSONDecoder()
        scoutingUserInfo = try? decoder.decode(ScoutingInfo.self, from: json.data(using: .utf8)!)
        print(scoutingUserInfo!)
        print("User is a \(scoutingUserInfo!.scouting.rank == 10 ? "seargent" : "private")")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
