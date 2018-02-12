//
//  AutonViewController.swift
//  scouting1072
//
//  Created by Aydin Tiritoglu on 2/9/18.
//  Copyright © 2018 Aydin Tiritoglu. All rights reserved.
//

var startingPosition = Float()
var autonStartTime = Double()
var teleOpStartTime = Double()
var autonStarted = false
var teleOpStarted = false
var autonPresses = [Double: String]()
var teleOpPresses = [Double: String]()
var timer = Timer()
var crossedLine = false

class AutonViewController: UIViewController {
    var counter = 0
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
        counter = 135
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
        // TODO: Transition to info-sending screen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldRotate = false
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        if scoutingUserInfo!.scouting.blue {
            fieldImage.transform = fieldImage.transform.rotated(by: CGFloat.pi)
        }
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
