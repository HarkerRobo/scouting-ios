//
//  Requests.swift
//  scouting1072
//
//  Created by Aydin Tiritoglu on 2/1/18.
//  Copyright © 2018 Aydin Tiritoglu. All rights reserved.
//

var inSession = false
var httpResponse : HTTPURLResponse? = nil
var task : URLSessionDataTask? = nil
var loggedIn = false

public func performRequest(requestType: RequestType) {
    if let _ = GIDSignIn.sharedInstance().currentUser?.profile.email {
        let dispatchGroup = DispatchGroup()
        if requestType != RequestType.none {
            let url = URL(string: "http://robotics.harker.org/member/token")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = requestType.description
            if requestType == .post && !loggedIn {
                let restString = "idtoken=\((user?.authentication.idToken)!)"
                request.httpBody = restString.data(using: .utf8)
            }
            dispatchGroup.enter()
            task = URLSession(configuration: .default).dataTask(with: request) { data, response, error in
                if let httpStatus = response as? HTTPURLResponse {
                    if httpStatus.statusCode != 200 {
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    } else {
                        print(httpStatus.statusCode as Any)
                        inSession = true
                    }
                    httpResponse = httpStatus
                    if let fields = httpResponse?.allHeaderFields as? [String : String] {
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response!.url!)
                        HTTPCookieStorage.shared.setCookies(cookies, for: response!.url!, mainDocumentURL: nil)
                        for cookie in cookies {
                            print(cookie.name)
                        }
                    }
                }
                print(httpResponse?.statusCode)
                dispatchGroup.leave()
            }
            switch requestType {
            case .delete:
                task?.cancel()
                task = nil
                inSession = false
            default: task?.resume()
            }
        }
        dispatchGroup.notify(queue: .main) {
            //SignInViewController.labelCheck()
        }
        print(user?.authentication.idToken as Any)
    }
}
