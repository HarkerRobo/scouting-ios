//
//  AutonViewController.swift
//  scouting1072
//
//  Created by Aydin Tiritoglu on 2/9/18.
//  Copyright © 2018 Aydin Tiritoglu. All rights reserved.
//

let impact = UIImpactFeedbackGenerator()
var appdelegate = AppDelegate()
var startingPosition = Float()
var autonStartTime = Double()
var teleOpStartTime = Double()
var autonStarted = false
var teleOpStarted = false
var autonUndo = [Double]()
var teleOpUndo = [Double]()
var autonPresses = [Double: String]()
var teleOpPresses = [Double: String]()
var autonControlTimes = [Double: String]()
var teleOpControlTimes = [Double: String]()
var timer = Timer()
var crossedLine = false

func showAlert(currentVC: UIViewController, title: String, text: String) {
    let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(action)
    currentVC.present(alertController, animated: true, completion: nil)
}

// 1 is red, 0 is neutral, -1 is blue
var redSwitch = 0 {
    didSet {
        print("changed")
    }
}
var scale = 0 {
    didSet {
        print("changed")
    }
}
var blueSwitch = 0 {
    didSet {
        print("changed")
    }
}

class FieldViewController: UIViewController {
    var counter = 0
    
    @IBOutlet weak var redControlRed: Switch!
    @IBOutlet weak var noneControlRed: Switch!
    @IBOutlet weak var blueControlRed: Switch!
    @IBOutlet weak var redControlScale: Switch!
    @IBOutlet weak var noneControlScale: Switch!
    @IBOutlet weak var blueControlScale: Switch!
    @IBOutlet weak var redControlBlue: Switch!
    @IBOutlet weak var noneControlBlue: Switch!
    @IBOutlet weak var blueControlBlue: Switch!
    @IBOutlet weak var redVaultCounter: UILabel!
    @IBOutlet weak var blueVaultCounter: UILabel!
    @IBOutlet weak var leftSwitchCounter: UILabel!
    @IBOutlet weak var scaleCounter: UILabel!
    @IBOutlet weak var rightSwitchCounter: UILabel!
    
    @IBAction func redControlRed(_ sender: Any) {
        redControlRed.layer.borderWidth = 100.0
        noneControlRed.layer.borderWidth = 5.0
        blueControlRed.layer.borderWidth = 5.0
    }
    @IBAction func noneControlRed(_ sender: Any) {
        redControlRed.layer.borderWidth = 5.0
        noneControlRed.layer.borderWidth = 100.0
        blueControlRed.layer.borderWidth = 5.0
    }
    @IBAction func blueControlRed(_ sender: Any) {
        redControlRed.layer.borderWidth = 5.0
        noneControlRed.layer.borderWidth = 5.0
        blueControlRed.layer.borderWidth = 100.0
    }
    @IBAction func redControlScale(_ sender: Any) {
        redControlScale.layer.borderWidth = 100.0
        noneControlScale.layer.borderWidth = 5.0
        blueControlScale.layer.borderWidth = 5.0
    }
    @IBAction func noneControlScale(_ sender: Any) {
        redControlScale.layer.borderWidth = 5.0
        noneControlScale.layer.borderWidth = 100.0
        blueControlScale.layer.borderWidth = 5.0
    }
    @IBAction func blueControlScale(_ sender: Any) {
        redControlScale.layer.borderWidth = 5.0
        noneControlScale.layer.borderWidth = 5.0
        blueControlScale.layer.borderWidth = 100.0
    }
    @IBAction func redControlBlue(_ sender: Any) {
        redControlBlue.layer.borderWidth = 100.0
        noneControlBlue.layer.borderWidth = 5.0
        blueControlBlue.layer.borderWidth = 5.0
    }
    @IBAction func noneControlBlue(_ sender: Any) {
        redControlBlue.layer.borderWidth = 5.0
        noneControlBlue.layer.borderWidth = 100.0
        blueControlBlue.layer.borderWidth = 5.0
    }
    @IBAction func blueControlBlue(_ sender: Any) {
        redControlBlue.layer.borderWidth = 5.0
        noneControlBlue.layer.borderWidth = 5.0
        blueControlBlue.layer.borderWidth = 100.0
    }
    
    @IBOutlet weak var initialPositionXConstraint: NSLayoutConstraint!
    @IBOutlet weak var undoHeight: NSLayoutConstraint!
    @IBOutlet weak var fieldImage: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var initialBotPosition: UISlider! {
        didSet {
            initialBotPosition.transform = CGAffineTransform(rotationAngle: scoutingUserInfo.scouting.blue ? -(CGFloat(Double.pi / 2)) : CGFloat(Double.pi / 2))
        }
    }
    
    @IBAction func undo(_ sender: Any) {
        if autonStarted {
            if sergeant {
                if let undoTime = autonUndo.last {
                    autonControlTimes.removeValue(forKey: undoTime)
                    autonUndo.removeLast()
                }
            } else {
                if let undoTime = autonUndo.last {
                    undoLabel(undoTime)
                    autonPresses.removeValue(forKey: undoTime)
                    autonUndo.removeLast()
                }
            }
        } else if teleOpStarted {
            if sergeant {
                if let undoTime = teleOpUndo.last {
                    teleOpControlTimes.removeValue(forKey: undoTime)
                    teleOpUndo.removeLast()
                }
            } else {
                if let undoTime = teleOpUndo.last {
                    undoLabel(undoTime)
                    teleOpPresses.removeValue(forKey: undoTime)
                    teleOpUndo.removeLast()
                }
            }
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        if actionButton.currentTitle == "Confirm Starting Position" {
            initialBotPosition.isEnabled = false
            startingPosition = initialBotPosition.value
            actionButton.setTitle("Start Auton", for: .normal)
        } else if actionButton.currentTitle == "Start Auton" {
            counter = 15
            autonStartTime = NSDate().timeIntervalSince1970
            autonStarted = true
            actionButton.setTitle("Auton Started", for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
            timer.fire()
        }
    }
    
    @objc func timerUpdate() {
        counter -= 1
        if counter <= -1 {
            timer.invalidate()
            if autonStarted {
                autonEnd()
            } else if teleOpStarted {
                teleOpEnd()
            }
        } else {
            timerLabel.text = "\(Int(counter / 60)):\(String(counter % 60).count == 2 ? "\(counter % 60)" : "0\(counter % 60)")"
        }
    }
    
    func autonEnd() {
        print(autonPresses)
        counter = 15//135
        autonStarted = false
        teleOpStartTime = NSDate().timeIntervalSince1970
        teleOpStarted = true
        actionButton.setTitle("TeleOp Started", for: .normal)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func teleOpEnd() {
        print(teleOpPresses)
        teleOpStarted = false
        timer.invalidate()
        startingPosition = initialBotPosition.value
        appdelegate.shouldRotate = true
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        performSegue(withIdentifier: "ToInfoSegue", sender: self)
    }
    
    func undoLabel(_ undoTime: Double) {
        switch teleOpStarted ? teleOpPresses[undoTime]! : autonPresses[undoTime]! {
        case "0_0_0":
            if scoutingUserInfo.scouting.blue {
                rightSwitchCounter.text = String(describing: Int(rightSwitchCounter.text!)! - 1)
            } else {
                leftSwitchCounter.text = String(describing: Int(leftSwitchCounter.text!)! - 1)
            }
        case "0_0_1":
            scaleCounter.text = String(describing: Int(scaleCounter.text!)! - 1)
        case "0_0_2":
            if scoutingUserInfo.scouting.blue {
                leftSwitchCounter.text = String(describing: Int(leftSwitchCounter.text!)! - 1)
            } else {
                rightSwitchCounter.text = String(describing: Int(rightSwitchCounter.text!)! - 1)
            }
        case "0_0_3":
            if scoutingUserInfo.scouting.blue {
                blueVaultCounter.text = String(describing: Int(blueVaultCounter.text!)! - 1)
            } else {
                redVaultCounter.text = String(describing: Int(redVaultCounter.text!)! - 1)
            }
        default: break
        }
    }
    
    @objc func newCubeHome() {
        if scoutingUserInfo.scouting.blue {
            let count = Int(rightSwitchCounter.text!)!
            rightSwitchCounter.text = String(describing: count + 1)
        } else {
            let count = Int(leftSwitchCounter.text!)!
            leftSwitchCounter.text = String(describing: count + 1)
        }
    }
    
    @objc func newCubeScale() {
        let count = Int(scaleCounter.text!)!
        scaleCounter.text = String(describing: count + 1)
    }
    
    @objc func newCubeAway() {
        if scoutingUserInfo.scouting.blue {
            let count = Int(leftSwitchCounter.text!)!
            leftSwitchCounter.text = String(describing: count + 1)
        } else {
            let count = Int(rightSwitchCounter.text!)!
            rightSwitchCounter.text = String(describing: count + 1)
        }
    }
    
    @objc func newCubeVault() {
        if scoutingUserInfo.scouting.blue {
            let count = Int(blueVaultCounter.text!)!
            blueVaultCounter.text = String(describing: count + 1)
        } else {
            let count = Int(redVaultCounter.text!)!
            redVaultCounter.text = String(describing: count + 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldRotate = false
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        if UIDevice.current.isSmall {
            undoHeight.constant -= 26.0
        }
        if scoutingUserInfo.scouting.blue {
            initialPositionXConstraint.constant = view.frame.maxX - 25.0
        } else {
            initialPositionXConstraint.constant = -133
        }
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(newCubeHome), name: NSNotification.Name.newCubeHome, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newCubeScale), name: NSNotification.Name.newCubeScale, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newCubeAway), name: NSNotification.Name.newCubeAway, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newCubeVault), name: NSNotification.Name.newCubeVault, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.delegate?.window??.rootViewController = self
        if sergeant {
            initialBotPosition.isHidden = true
            actionButton.setTitle("Start Auton", for: .normal)
        } else {
            showAlert(currentVC: self, title: "You are scouting team #\(scoutingUserInfo.scouting.team)", text: "")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        initialBotPosition.transform = CGAffineTransform(rotationAngle: scoutingUserInfo.scouting.blue ? CGFloat(Double.pi / 2) : -(CGFloat(Double.pi / 2)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeLeft
    }
    
    private func shouldAutorotate() -> Bool {
        return true
    }
}
