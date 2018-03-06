//
//  AutonViewController.swift
//  scouting1072
//
//  Created by Aydin Tiritoglu on 2/9/18.
//  Copyright © 2018 Aydin Tiritoglu. All rights reserved.
//

var appdelegate = AppDelegate()
var startingPosition = Float()
var autonStartTime = Double()
var teleOpStartTime = Double()
var autonStarted = false
var teleOpStarted = false
var autonPresses = [Double: String]()
var teleOpPresses = [Double: String]()
var autonControlTimes = [Double: String]()
var teleOpControlTimes = [Double: String]()
var timer = Timer()
var crossedLine = false

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
    
    @IBOutlet weak var fieldImage: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var initialBotPosition: UISlider! {
        didSet {
            initialBotPosition.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: Any) {
        if actionButton.currentTitle == "Confirm Starting Position" {
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
        performSegue(withIdentifier: "ToInfoSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldRotate = false
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        if scoutingUserInfo.scouting.blue {
            fieldImage.transform = fieldImage.transform.rotated(by: CGFloat.pi)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.delegate?.window??.rootViewController = self
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
