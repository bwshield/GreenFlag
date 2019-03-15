//
//  CoreDataBastard.swift
//  GreenFlag
//
//  Created by B Shield on 1/30/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class CoreDataBastard {
    
    // MARK: - Core Data stack
    static let sharedBastard = CoreDataBastard()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "GreenFlag3")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 
                 
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func getUserAttribute (attribute: String) -> UserAttributes? {
        
        var userAttribute : UserAttributes?
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAttributes")
        let predicate = NSPredicate(format: "attribute == %@", attribute)
        fetchRequest.predicate = predicate
        let fetchedAttributes = try? self.persistentContainer.viewContext.fetch(fetchRequest) as! [UserAttributes]
        if (fetchedAttributes != nil) {
            if (fetchedAttributes?.count != 0) {
                userAttribute = fetchedAttributes?.first
            }
        }
        return userAttribute
    }
    
    public func setUserAttribute (attribute: String, value: String) {
        var userAttribute = getUserAttribute(attribute: attribute)
        if (userAttribute != nil) {
            userAttribute?.value = value
        } else {
            userAttribute = NSEntityDescription.insertNewObject(forEntityName: "UserAttributes", into: persistentContainer.viewContext) as? UserAttributes
            userAttribute?.attribute = attribute
            userAttribute?.value = value
        }
        //self.saveContext()
    }
    public func nextEvent () -> Events {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "endDate >= %@", NSDate())
        fetchRequest.predicate = predicate
        let managedObjectContext = self.persistentContainer.viewContext
        let fetchResults = try! managedObjectContext.fetch(fetchRequest) as! [Events]       // *** this likes to fail during watch complication uppdate
        let nextEvent = fetchResults.first
        return nextEvent!
    }
    
    public func eventStartGMT(event: Events) -> Date? {
        let endDate = (event.endDate)! as Date
        let startTime = (event.startTime)! as Date
        let eventDate = endDate.addingTimeInterval(startTime.timeIntervalSinceReferenceDate)
        let eventTZ = TimeZone(identifier: event.timezone!)
        let eventIntervalDiff = eventTZ?.secondsFromGMT(for: eventDate)
        var gmtDate : Date? = nil
        if eventIntervalDiff != nil {
            gmtDate = eventDate.addingTimeInterval(-Double(eventIntervalDiff!))
        }
        return gmtDate
    }
    
    public func eventStartLocal(event: Events) -> (Date?, TimeZone?) {
        let gmtDate = eventStartGMT(event: event)
        if gmtDate != nil {
            let localTZ = TimeZone.autoupdatingCurrent
            let localDate = gmtDate!.addingTimeInterval(Double(localTZ.secondsFromGMT(for: gmtDate!)))
            return (localDate,localTZ)
        }
        return (nil, nil)
    }
    
    public func eventStartVenue(event: Events) -> (Date?, TimeZone?) {
        let gmtDate = eventStartGMT(event: event)
        if gmtDate != nil {
            let venueTZ = TimeZone(identifier: event.venue!.timezone!)
            let venueDate = gmtDate!.addingTimeInterval(Double(venueTZ!.secondsFromGMT(for: gmtDate!)))
            return (venueDate,venueTZ!)
        }
        return (nil,nil)
    }
    
    public func formattedStart(date: Date, timeZone: TimeZone) -> (String, String, String) {
        var is24 : Bool = true
        let test24 : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale:Locale.current)!
        if test24.contains("a") {
            is24 = false
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        let formattedDate = formatter.string(from: date)
        if is24 {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "h:mm a"
        }
        let time = formatter.string(from: date)
        let zone = timeZone.abbreviation(for: date)
        return (formattedDate, time, zone!)
    }
    
    public func formattedStartLocal(event: Events) -> (String, String, String) {
        let (eventDate,eventTZ) = eventStartLocal(event: event)
        if eventDate != nil && eventTZ != nil {
            let (date, time, zone) = formattedStart(date: eventDate!, timeZone: eventTZ!)
            return (date, time, zone)
        } else {
            return ("*time*","*zone*","*error*")
        }
    }
    
    public func formattedStartVenue(event: Events) -> (String, String, String) {
        let (eventDate,eventTZ) = eventStartVenue(event: event)
        if eventDate != nil && eventTZ != nil {
            let (date, time, zone) = formattedStart(date: eventDate!, timeZone: eventTZ!)
            return (date, time, zone)
        } else {
            return ("*time*","*zone*","*error*")
        }
    }
    
    public func startDetailLong(event: Events) -> (String) {
        let (localDate,localTime,localZone) = formattedStartLocal(event: event)
        let (venueDate,venueTime,venueZone) = formattedStartVenue(event: event)
        var venueTimeDetail = ""
        if localDate != venueDate {
            venueTimeDetail.append(venueDate + " ")
        }
        if localTime != venueTime {
            venueTimeDetail.append(venueTime + " " + venueZone)
        }
        var detailText = localDate + " " + localTime + " " + localZone
        if venueTimeDetail.count > 0 {
            detailText.append(" (" + venueTimeDetail + ")")
        }
        return detailText
    }
    
    public func startDetailWatch(event: Events) -> (String, String) {
        let (localDate,localTime,localZone) = formattedStartLocal(event: event)
        let label2 = localDate
        let label3 = localTime + " " + localZone
        return (label2, label3)
    }
    
    public func dateFromISODescription(from: String?) -> Date? {
        if from == nil {
            return nil
        }
        //let formatter = DateFormatter()
        //formatter.dateFormat = "YYYY-MM-DD HH:MM:SS Z"
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: from!)
        return date
    }
    public func ISODescriptionFromDate(date: Date?) -> String? {
        if date == nil {
            return nil
        }
        let formatter = ISO8601DateFormatter()
        let dateDescription = formatter.string(from: date!)
        return dateDescription
    }
    public func checkForUpdateFile() -> Bool{
        let userAttribute = getUserAttribute(attribute: "fulldataversion")
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = paths.first
        let localurl = documentsURL?.appendingPathComponent("greenflag.xml")
        if (userAttribute == nil) {
            let bundlePath = Bundle.main.url(forResource: "greenflag", withExtension: ".xml")
            try! fileManager.copyItem(at: bundlePath!, to: localurl!)
        }
        if fileManager.fileExists(atPath: (localurl?.path)!) {
            do {
                let fileAttributes = try fileManager.attributesOfItem(atPath: localurl!.path)
                let fileSize = fileAttributes[FileAttributeKey.size] as! UInt64
                if fileSize < 2048 {
                    try fileManager.removeItem(at: localurl!)
                    return false
                }
            } catch {
                print("file error")
            }
            return true
        }
        return false
    }
    public func venueMapInfo(venue: Venues) -> (CLLocationCoordinate2D? ){
        let latitudeAttribute = getVenueAttribute(venue: venue, attribute: "latitude")
        let longitudeAttribute = getVenueAttribute(venue: venue, attribute: "longitude")
        if (latitudeAttribute != nil && longitudeAttribute != nil) {
            let latitude = Double(latitudeAttribute!.value!)
            let longitude = Double(longitudeAttribute!.value!)
            let location = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            return location
        }
    return nil
    }
    public func getVenueAttribute(venue: Venues, attribute: String) -> VenueAttributes? {
        if venue.attributes != nil {
            if venue.attributes!.count > 0 {
                for venueAttribute in venue.attributes!.allObjects as! [VenueAttributes] {
                    if venueAttribute.attribute == attribute {
                        return venueAttribute
                    }
                }
            }
        }
        return nil
    }
    public func parseUpdateFile() {
        //let userAttribute = coreDataBastard.getUserAttribute(attribute: "fulldataversion")
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = paths.first
        let localurl = documentsURL?.appendingPathComponent("greenflag.xml")
        let parsesuccess = XMLCheckForUpdate.init()
        parsesuccess.parse(url: localurl!)
        try? FileManager.default.removeItem(at: localurl!)
    }
}
