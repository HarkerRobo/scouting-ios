//
//  Switch.swift
//  scouting1072
//
//  Created by Aydin Tiritoglu on 2/11/18.
//  Copyright © 2018 Aydin Tiritoglu. All rights reserved.
//

import UIKit
import AudioToolbox

class Switch: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(onPress), for: .touchDown)
        self.addTarget(self, action: #selector(onRelease), for: .touchUpInside)
        self.setTitleColor(UIColor.clear, for: .normal)
        self.layer.borderColor = scoutingUserInfo.scouting.rank == 10 ? UIColor.gray.cgColor : scoutingUserInfo.scouting.blue ? UIColor.blue.cgColor : UIColor.red.cgColor
        self.layer.borderWidth = 5.0
        // MARK: When I wrote this next section, only I and the compiler understood it. Now only the compiler understands it. If you mess with this code, home vs. away will be very broken, so don't.
        if self.frame.midX <= 300 && (self.titleLabel?.text == "0_0_2" || self.titleLabel?.text == "0_0_0") {
            self.titleLabel?.text = scoutingUserInfo.scouting.blue ? "0_0_2" : "0_0_0"
        }
        if self.frame.midX >= 300 && (self.titleLabel?.text == "0_0_2" || self.titleLabel?.text == "0_0_0") {
            self.titleLabel?.text = scoutingUserInfo.scouting.blue ? "0_0_0" : "0_0_2"
        }
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
            if self.titleLabel?.text == "0_0_3" {
                self.isHidden = true
            }
        } else {
            self.layer.borderColor = scoutingUserInfo.scouting.blue ? UIColor.blue.cgColor : UIColor.red.cgColor
            if self.titleLabel?.text == "0_0_3" {
                if self.frame.midX >= 300 {
                    self.isHidden = !scoutingUserInfo.scouting.blue
                } else {
                    self.isHidden = scoutingUserInfo.scouting.blue
                }
            }
            if self.titleLabel?.text?.first == Character("1") {
                self.isHidden = true
            }
        }
    }
    
    func updateLabel() {
        if let name = self.titleLabel?.text{
            switch name {
            case "0_0_0":
                NotificationCenter.default.post(Notification(name: .newCubeHome))
            case "0_0_1":
                NotificationCenter.default.post(Notification(name: .newCubeScale))
            case "0_0_2":
                NotificationCenter.default.post(Notification(name: .newCubeAway))
            case "0_0_3":
                NotificationCenter.default.post(Notification(name: .newCubeVault))
            default: break
            }
        }
    }
    
    @objc func onPress() {
        if !sergeant && (autonStarted || teleOpStarted) {
            self.layer.borderWidth = 100.0
        }
    }
    
    @objc func onRelease() {
        print("Switch Pressed")
        if autonStarted {
            impact.impactOccurred()
            if UIDevice.current.hasHapticFeedback {
                impact.impactOccurred()
            } else {
                vibrate()
            }
            let date = NSDate().timeIntervalSince1970
            if sergeant {
                autonControlTimes[date] = self.titleLabel?.text
            } else {
                autonPresses[date] = self.titleLabel?.text
            }
            autonUndo.append(date)
            updateLabel()
        } else if teleOpStarted {
            if UIDevice.current.hasHapticFeedback {
                impact.impactOccurred()
            } else {
                vibrate()
            }
            let date = NSDate().timeIntervalSince1970
            if sergeant {
                teleOpControlTimes[date] = self.titleLabel?.text
            } else {
                teleOpPresses[date] = self.titleLabel?.text
            }
            teleOpUndo.append(date)
            updateLabel()
        }
        self.layer.borderWidth = 5.0
    }
}
