//
//  AppDelegate.swift
//  GreenFlag
//
//  Created by Brian Shield on 1/13/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

typealias CompleteHandlerBlock = () -> ()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, URLSessionDelegate, URLSessionDownloadDelegate {
    
    //var handlerQueue: [String : CompleteHandlerBlock]!
    
    var window: UIWindow?
    let coreDataBastard = CoreDataBastard.sharedBastard
    var urlCompletionHandler: (() -> Void)?
    var sessionTask: URLSessionDownloadTask?
    var urlString : String?
    var urlSession : URLSession?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //managedObjectContext = CoreDataBastard.sharedBastard.persistentContainer.viewContext
        let config = URLSessionConfiguration.background(withIdentifier: "greenflag")
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert,.sound,.badge]) { (granted, error) in
            // set up
            if (granted) {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        }
        // setup URL Session for update requests
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let userAttribute = CoreDataBastard.sharedBastard.getUserAttribute(attribute: "notificationsDeviceToken")
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        if (userAttribute != nil) {
            userAttribute?.value = tokenString
        } else {
            CoreDataBastard.sharedBastard.setUserAttribute(attribute: "notificationsDeviceToken", value: tokenString)
        }
        beginTokenUpload(token: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("failed to register APN")
    }
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        urlCompletionHandler = completionHandler
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
        // if update request not in progress, send one
        if coreDataBastard.checkForUpdateFile() {
            coreDataBastard.parseUpdateFile()
        }
        if (sessionTask == nil) {
            beginDownLoadTask()
        }
    }
    
    func beginDownLoadTask() {
        let versionAttribute = CoreDataBastard.sharedBastard.getUserAttribute(attribute: "fulldataversion")
        let sessionTask = urlSession?.downloadTask(with: URL(string: String(format: "https://greenflag.honestinfo.net/fulldata3.php?fulldataversion=%@", versionAttribute?.value ?? "0" ))!)
        sessionTask?.countOfBytesClientExpectsToSend = 100
        sessionTask?.countOfBytesClientExpectsToReceive = 80 * 1024
        sessionTask?.resume()
    }
    func beginTokenUpload(token: Data) {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()
        let fullToken = "deviceToken=" + tokenString
        let url = URL(string: "https://greenflag.honestinfo.net/registertoken3.php")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        let dataToken = fullToken.data(using: String.Encoding.utf8)
        urlRequest.httpBody = dataToken
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(String(format: "%ld",(dataToken?.count)! ), forHTTPHeaderField: "Content-Length")
        let postTask = urlSession?.dataTask(with: urlRequest)
        postTask?.resume()
    }
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // cleanup URLSession?
        sessionTask = nil
        if (urlSession != nil) {
            urlSession!.invalidateAndCancel()
        }
    }
    /*
    func checkForUpdateFile() -> Bool{
        let userAttribute = coreDataBastard.getUserAttribute(attribute: "fulldataversion")
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = paths.first
        let localurl = documentsURL?.appendingPathComponent("greenflag.xml")
        if (userAttribute == nil) {
            let bundlePath = Bundle.main.url(forResource: "greenflag", withExtension: ".xml")
            try! fileManager.copyItem(at: bundlePath!, to: localurl!)
        }
        if fileManager.fileExists(atPath: (localurl?.path)!) {
            return true
        }
        return false
    }
    
    func parseUpdateFile() {
        //let userAttribute = coreDataBastard.getUserAttribute(attribute: "fulldataversion")
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = paths.first
        let localurl = documentsURL?.appendingPathComponent("greenflag.xml")
        let parsesuccess = XMLCheckForUpdate.init()
        parsesuccess.parse(url: localurl!)
        try? FileManager.default.removeItem(at: localurl!)
    }
    */
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = paths.first
        let localurl = documentsURL?.appendingPathComponent("greenflag.xml")
        if fileManager.fileExists(atPath: (localurl?.path)!) {
            try! fileManager.removeItem(at: localurl!)
        }
         do {
            try fileManager.moveItem(at: location, to: localurl!)
        } catch {
            print("file not there")
        }
        print("download complete")
        sessionTask = nil
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        urlSession = nil
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        sessionTask = nil
    }
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if (urlCompletionHandler != nil) {
            let completionHandler = urlCompletionHandler!
            urlCompletionHandler = nil
            completionHandler()
        }
    }
}



