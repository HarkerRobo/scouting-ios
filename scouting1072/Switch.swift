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
        self.layer.borderColor = scoutingUserInfo.scouting.rank == 10 ? UIColor.gray.cgColor : scoutingUserInfo.scouting.blue ? UIColor.blue.cgColor : UIColor.red.cgColor
        self.layer.borderWidth = 5.0
        if sergeant {
            if self.titleLabel?.text?.first == Character("0") {
                self.isHidden = true
            }
            let lastChar = self.titleLabel?.text?.last
            switch lastChar {
            case Character("0")?, Character("3")?, Character("6")?:
                self.layer.borderColor = UIColor.red.cgColor
            case Character("2")?, Character("5")?, Character("8")?:
                self.layer.borderColor = UIColor.blue.cgColor
            default:
                self.layer.borderColor = UIColor.lightGray.cgColor
                self.layer.borderWidth = 100.0
            }
        } else {
            if self.titleLabel?.text?.first == Character("1") {
                self.isHidden = true
            }
        }
    }
    
    @objc func onPress() {
        print("Switch Pressed")
        if autonStarted {
            if sergeant {
                autonControlTimes[NSDate().timeIntervalSince1970] = self.titleLabel?.text
            } else {
                autonPresses[NSDate().timeIntervalSince1970] = self.titleLabel?.text
            }
        } else if teleOpStarted {
            if sergeant {
                teleOpControlTimes[NSDate().timeIntervalSince1970] = self.titleLabel?.text
            } else {
                teleOpPresses[NSDate().timeIntervalSince1970] = self.titleLabel?.text
            }
        }
    }
}
