//
//  AppDelegate.swift
//  scouting1072
//
//  Created by Aydin Tiritoglu on 1/25/18.
//  Copyright © 2018 Aydin Tiritoglu. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let userSignedIn = Notification.Name("userSignedIn")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    

    var session = URLSession(configuration: .default)
    var window : UIWindow?
    
    var hostname = "https://robotics.harker.org"
    
    static func shared() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var shouldRotate = true
    
    //MARK: - Func to rotate only one view controller
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if (shouldRotate == true){
            return UIInterfaceOrientationMask.portrait
        }
        return UIInterfaceOrientationMask.landscape
        
    }
    
    var inSession = false
    var httpResponse : HTTPURLResponse? = nil
    var task : URLSessionDataTask? = nil
    var loggedIn = false
    var fromSelf = false
    
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        
        let hauthToken = url.absoluteString.replacingOccurrences(of: "scouting1072://login?token=", with: "hauth")

        let dispatchGroup = DispatchGroup()
        let url = URL(string: hostname + "/member/token")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "post"
        
            let restString = "idtoken=\(hauthToken)"
            request.httpBody = restString.data(using: .utf8)
        
        dispatchGroup.enter()
        
        var task : URLSessionDataTask? = nil
        task = session.dataTask(with: request) { data, response, error in
            if let httpStatus = response as? HTTPURLResponse {
                if httpStatus.statusCode != 200 {
                    let alertController = UIAlertController(title: "Signin Error", message: "Your signin request has expired. Please try again. ", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                    return;
                }
                
                self.httpResponse = httpStatus
                if let fields = self.httpResponse?.allHeaderFields as? [String : String] {
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response!.url!)
                    HTTPCookieStorage.shared.setCookies(cookies, for: response!.url!, mainDocumentURL: nil)
                    for cookie in cookies {
                        print(cookie.name)
                    }
                }
                
                NotificationCenter.default.post(name: NSNotification.Name("userSignedIn"), object: nil, userInfo: nil)

            }
            print(self.httpResponse?.statusCode as Any)
            dispatchGroup.leave()
        }
        task?.resume();
//        dispatchGroup.notify(queue: .main) {
//            if self.fromSelf {
//                self.labelCheck()
//                self.performSegue(withIdentifier: "SignInToInterSegue", sender: self)
//            }
//        }
        
        return true
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                hostname = dict["hostname"] as! String
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

