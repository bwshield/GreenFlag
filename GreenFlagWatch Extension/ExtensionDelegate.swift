//
//  ExtensionDelegate.swift
//  GreenFlagWatch Extension
//
//  Created by B Shield on 1/22/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import WatchKit
import CoreData

class ExtensionDelegate: NSObject, WKExtensionDelegate, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    var urlSession : URLSession?
    var sessionTask: URLSessionDownloadTask?
    var backgroundDataUpdateTaskScheduled: Bool = false
    let backgroundDataUpdateInterval : Double = 120   // **** one hour = 3600
    let backgroundHTTPUpdateInterval : Double = 600  // **** 24 hours = 86400
    var coreDataBastard = CoreDataBastard.sharedBastard
    
    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        setupURLSession()
    }
    func applicationWillEnterForeground() {
        // check it out
    }
    func applicationDidEnterBackground() {
        // check it out
    }
    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // ** check time interval and/or check version on phone
        updateComplications(error: nil)
        let userAttribute = CoreDataBastard.sharedBastard.getUserAttribute(attribute: "fulldataversion")
        if userAttribute == nil {
            beginDownloadTask()
        }
        checkForUpdateFile()
        scheduleBackgroundDataDowloadUpdate(delay: backgroundDataUpdateInterval)
        //scheduleBackgroundComplicationsUpdate(delay: 60 * 30)
        //scheduleBackgroundDataFileCheckUpdate(delay: 60)
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                backgroundDataUpdateTaskScheduled = false
                let lastupdateAttribute = coreDataBastard.getUserAttribute(attribute: "lastupdate")
                if lastupdateAttribute == nil {
                    beginDownloadTask()
                } else {
                    let lastdate = coreDataBastard.dateFromISODescription(from: lastupdateAttribute?.value)
                    if lastdate != nil {
                        if lastdate! + TimeInterval(exactly: backgroundHTTPUpdateInterval)! < Date() {
                            beginDownloadTask()
                            print ("update started")
                        } else {
                            print ("not time yet")
                        }
                    }
                }
                checkForUpdateFile()
                updateComplications(error: nil)
                backgroundTask.setTaskCompletedWithSnapshot(false)
                scheduleBackgroundDataDowloadUpdate(delay: backgroundDataUpdateInterval)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    /*
    func scheduleBackgroundComplicationsUpdate(delay: TimeInterval) {
        if !backgroundComplicationsTaskScheduled {
            let firedate = Date(timeIntervalSinceNow: delay)
            let userInfo = NSDictionary(dictionary: ["tasktype" : "complications" ])
            WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: firedate, userInfo: userInfo) { (error) in
                if error == nil {
                    print ("background task scheduled")
                    self.backgroundComplicationsTaskScheduled = true
                } else {
                    print ("background task not scheduled")
                }
            }
        } else {
            print ("background task already scheduled")
        }
    }
 */
    func scheduleBackgroundDataDowloadUpdate(delay: TimeInterval) {
        if !backgroundDataUpdateTaskScheduled {
            let firedate = Date(timeIntervalSinceNow: delay)
            let userInfo = NSDictionary(dictionary: ["tasktype" : "dataupdate" ])
            WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: firedate, userInfo: userInfo) { (error) in
                if error == nil {
                    print ("background task scheduled")
                    self.backgroundDataUpdateTaskScheduled = true
                } else {
                    print ("background task not scheduled")
                }
            }
        } else {
            print ("background task already scheduled")
        }
    }
    /*
    func scheduleBackgroundDataFileCheckUpdate(delay: TimeInterval) {
        if !backgroundDataFileCheckTaskScheduled {
            let firedate = Date(timeIntervalSinceNow: delay)
            let userInfo = NSDictionary(dictionary: ["tasktype" : "datafilecheck" ])
            WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: firedate, userInfo: userInfo) { (error) in
                if error == nil {
                    print ("background task scheduled")
                    self.backgroundDataFileCheckTaskScheduled = true
                } else {
                    print ("background task not scheduled")
                }
            }
        } else {
            print ("background task already scheduled")
        }
    }
 */
    func updateComplications(error: Error?) {
        let clkServer = CLKComplicationServer.sharedInstance()
        let complications = clkServer.activeComplications
        if (complications != nil) {
            if complications!.count > 0 {
                for complication in complications! {
                    clkServer.reloadTimeline(for: complication)
                }
            }
        }
        print("complications updated")
    }
    func checkForUpdateFile() {
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
            let parsesuccess = XMLCheckForUpdate.init()
            parsesuccess.parse(url: localurl!)
            try? FileManager.default.removeItem(at: localurl!)
        }
    }
    func setupURLSession() {
        let config = URLSessionConfiguration.background(withIdentifier: "greenflag")
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    func beginDownloadTask() {
        let versionAttribute = CoreDataBastard.sharedBastard.getUserAttribute(attribute: "fulldataversion")
        sessionTask = urlSession?.downloadTask(with: URL(string: String(format: "https://greenflag.honestinfo.net/fulldata3.php?fulldataversion=%@", versionAttribute?.value ?? "0" ))!)
        sessionTask?.countOfBytesClientExpectsToSend = 100
        sessionTask?.countOfBytesClientExpectsToReceive = 80 * 1024
        sessionTask?.resume()
        print("session started")
    }

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
            let fileAttributes = try fileManager.attributesOfItem(atPath: localurl!.absoluteString)
            let fileSize = fileAttributes[FileAttributeKey.size] as! UInt64
            if fileSize < 2048 {
                try fileManager.removeItem(at: localurl!)
            }
        } catch {
            print("file not there")
        }
        print ("download finished")
        sessionTask = nil
        // store local file in CoreData userattributes?
    }
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("session error")
        sessionTask = nil
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let now = coreDataBastard.ISODescriptionFromDate(date: Date())
        if now != nil {
            coreDataBastard.setUserAttribute(attribute: "lastupdate", value: now!)
        }
        print("Session did complete")
        sessionTask = nil
    }
}
