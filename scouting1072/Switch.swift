//
//  Switch.swift
//  scouting1072
//
//  Created by Aydin Tiritoglu on 2/11/18.
//  Copyright © 2018 Aydin Tiritoglu. All rights reserved.
//

import UIKit

class Switch: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(onPress), for: .touchUpInside)
        self.setTitleColor(UIColor.clear, for: .normal)
        self.layer.borderColor = scoutingUserInfo!.scouting.blue ? UIColor.blue.cgColor : UIColor.red.cgColor
        self.layer.borderWidth = 5.0
    }
    
    @objc func onPress() {
        print("Switch Pressed \(autonStarted ? "During" : "Before") Auton")
        if autonStarted {
            autonPresses[NSDate().timeIntervalSince1970] = self.titleLabel?.text
        } else if teleOpStarted {
            teleOpPresses[NSDate().timeIntervalSince1970] = self.titleLabel?.text
        }
    }
}
