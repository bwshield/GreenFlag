//
//  XMLCheckForUpdate.swift
//  GreenFlag
//
//  Created by Brian Shield on 1/13/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class XMLCheckForUpdate : NSObject, XMLParserDelegate {
    
    var currentTable : String? = nil
    var localManagedObjectContext: NSManagedObjectContext? = nil
    var currentSeries : Series? = nil
    var currentVenue : Venues? = nil
    var currentEvent : Events? = nil
    var currentValue : String = ""
    var currentSeriesAttribute : SeriesAttributes? = nil
    var currentVenueAttribute : VenueAttributes? = nil
    var currentEventAttribute : EventAttributes? = nil
    var currentAttributeTable : String? = nil
    
    func truncTable (tableName:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try localManagedObjectContext?.execute(deleteRequest)
        } catch {
           // NSLog("error deleting objects: %@", tableName)
        }
    }
    
    func parser (_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "allseries":
            truncTable(tableName: "Series")
            truncTable(tableName: "SeriesAttributes")
            truncTable(tableName: "Events")
            truncTable(tableName: "EventAttributes")
        case "venues":
            truncTable(tableName: "Venues")
            truncTable(tableName: "VenueAttributes")
            
        case "series":
            currentTable = "Series"
            currentAttributeTable = nil
            currentSeries = NSEntityDescription.insertNewObject(forEntityName: "Series", into: localManagedObjectContext!) as? Series
            currentSeries?.managedObjectContext?.performAndWait {
                currentSeries?.seriesID = attributeDict["id"]
            }
        case "venue":
            currentTable = "Venues"
            currentAttributeTable = nil
            currentVenue = NSEntityDescription.insertNewObject(forEntityName: "Venues", into: localManagedObjectContext!) as? Venues
            currentVenue?.managedObjectContext?.performAndWait {
                currentVenue?.venueID = attributeDict["id"]
            }
        case "event":
            currentTable = "Events"
            currentAttributeTable = nil
            currentEvent = NSEntityDescription.insertNewObject(forEntityName: "Events", into: localManagedObjectContext!) as? Events
            currentEvent?.managedObjectContext?.performAndWait {
                currentEvent?.eventID = attributeDict["id"]
            }
        case "seriesAttribute":
            currentAttributeTable = "SeriesAttributes"
            currentSeriesAttribute = NSEntityDescription.insertNewObject(forEntityName: "SeriesAttributes", into: localManagedObjectContext!) as? SeriesAttributes
            currentSeriesAttribute?.managedObjectContext?.performAndWait {
                currentSeries?.addToAttributes(currentSeriesAttribute!)
                currentSeriesAttribute?.seriesAttributeID = attributeDict["id"]
            }
        case "venueAttribute":
            currentAttributeTable = "VenueAttributes"
            currentVenueAttribute = NSEntityDescription.insertNewObject(forEntityName: "VenueAttributes", into: localManagedObjectContext!) as? VenueAttributes
            currentVenueAttribute?.managedObjectContext?.performAndWait {
                currentVenue?.addToAttributes(currentVenueAttribute!)
                currentVenueAttribute?.venueAttributeID = attributeDict["id"]
            }
        case "eventAttribute":
            currentAttributeTable = "EventAttributes"
            currentEventAttribute = NSEntityDescription.insertNewObject(forEntityName: "EventAttributes", into: localManagedObjectContext!) as? EventAttributes
            currentEventAttribute?.managedObjectContext?.performAndWait {
                currentEvent?.addToAttributes(currentEventAttribute!)
                currentEventAttribute?.eventAttributeID = attributeDict["id"]
            }
        default:
            currentValue = ""
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
        //NSLog("string:%@,currentValue:%@",string,currentValue)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        timeFormatter.timeZone = TimeZone(abbreviation: "UTC")
        switch elementName {
        //case "greenflag":
            //try? localManagedObjectContext?.save()
        case "fulldataversion":
            CoreDataBastard.sharedBastard.setUserAttribute(attribute: "fulldataversion", value: currentValue)
        case "event":
            // attach to venue and series, and parent event if applicable
            let venueFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Venues")
            let venuePredicate = NSPredicate(format: "venueID == %@", (currentEvent?.venueID)!)
            venueFetchRequest.predicate = venuePredicate
            let venueResult = try? localManagedObjectContext?.fetch(venueFetchRequest) as! [Venues]
            if (venueResult != nil) {
                let venue : Venues? = venueResult?.first
                currentEvent?.venue = venue
            }
            let seriesFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Series")
            let seriesPredicate = NSPredicate(format: "seriesID == %@",(currentEvent?.seriesID)!)
            seriesFetchRequest.predicate = seriesPredicate
            let seriesResult = try? localManagedObjectContext?.fetch(seriesFetchRequest) as! [Series]
            if (seriesResult != nil) {
                let series : Series? = seriesResult?.first
                currentEvent?.series = series
            }
            let parentEventID = currentEvent?.parentEventID
            if (parentEventID != nil) {
                if (parentEventID!.count > 0 && parentEventID! != "0") {
                    let parentFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
                    let parentPredicate = NSPredicate(format: "eventID == %@", (currentEvent?.parentEventID)!)
                    parentFetchRequest.predicate = parentPredicate
                    let parentResult = try? localManagedObjectContext?.fetch(parentFetchRequest) as! [Events]
                    if (parentResult != nil) {
                        let parent : Events? = parentResult?.first
                        currentEvent?.parent = parent
                    }
                }
            }
        default:
            switch currentTable {
            case "Series":
                switch currentAttributeTable {
                case "SeriesAttributes":
                    switch elementName {
                    case "attribute":
                        currentSeriesAttribute?.attribute = currentValue
                    case "value":
                        currentSeriesAttribute?.value = currentValue
                    case "visible":
                        switch currentValue {
                        case "0":
                            currentSeriesAttribute?.visible = false
                        default:
                            currentSeriesAttribute?.visible = true
                        }
                    default:
                        break
                    }
                default:
                    switch elementName {
                    case "title":
                        //NSLog("seriesTitle:%@", currentValue)
                        currentSeries?.title = currentValue
                    case "tag":
                        currentSeries?.tag = currentValue
                    case "seriesDate":
                        //NSLog("seriesDate:%@", currentValue)
                        currentSeries?.startDate = dateFormatter.date(from: currentValue)
                    case "seriesEnd":
                        currentSeries?.endDate = dateFormatter.date(from: currentValue)
                    case "deleted":
                        switch currentValue {
                        case "0":
                            currentSeries?.isdeleted = false
                        default:
                            currentSeries?.isdeleted = true
                        }
                    case "shortTitle":
                        currentSeries?.shortTitle = currentValue
                    case "sortorder":
                        currentSeries?.sortorder = Int16(currentValue)!
                    case "section":
                        currentSeries?.section = currentValue
                    default:
                        break
                    }
                }
            case "Venues":
                switch currentAttributeTable {
                case "VenueAttributes":
                    switch elementName {
                    case "attribute":
                        currentVenueAttribute?.attribute = currentValue
                    case "value":
                        currentVenueAttribute?.value = currentValue
                    case "visible":
                        switch currentValue {
                        case "0":
                            currentVenueAttribute?.visible = false
                        default:
                            currentVenueAttribute?.visible = true
                        }
                    default:
                        break
                    }
                default:
                    switch elementName {
                    case "title":
                        currentVenue?.title = currentValue
                        //NSLog("currentVenue:%@", currentValue)
                    case "tag":
                        currentVenue?.tag = currentValue
                    case "deleted":
                        switch currentValue {
                        case "0":
                            currentVenue?.isdeleted = false
                        default:
                            currentVenue?.isdeleted = true
                        }
                    case "shortTitle":
                        currentVenue?.shorttitle = currentValue
                    case "timezone":
                        currentVenue?.timezone = currentValue
                    case "continent":
                        currentVenue?.continent = currentValue
                    default:
                        break
                    }
                }
            case "Events":
                switch currentAttributeTable {
                case "EventAttributes":
                    switch elementName {
                    case "attribute":
                        currentEventAttribute?.attribute = currentValue
                    case "value":
                        currentEventAttribute?.value = currentValue
                    case "visible":
                        switch currentValue {
                        case "0":
                            currentEventAttribute?.visible = false
                        default:
                            currentEventAttribute?.visible = true
                        }
                    default:
                        break
                    }
                default:
                    switch elementName {
                    case "tag":
                        currentEvent?.tag = currentValue
                    case "eventStart":
                        currentEvent?.startDate = dateFormatter.date(from: currentValue) as NSDate?
                    case "eventEnd":
                        currentEvent?.endDate = dateFormatter.date(from: currentValue) as NSDate?
                    case "eventTime":
                        currentEvent?.startTime = timeFormatter.date(from: "2001-01-01 " + currentValue) as NSDate?
                    case "timezone":
                        currentEvent?.timezone = currentValue
                    case "title":
                        currentEvent?.title = currentValue
                    case "parentEventID":
                        currentEvent?.parentEventID = currentValue
                    case "venueID":
                        currentEvent?.venueID = currentValue
                    case "seriesID":
                        currentEvent?.seriesID = currentValue
                    case "deleted":
                        switch currentValue {
                        case "0":
                            currentEvent?.isdeleted = false
                        default:
                            currentEvent?.isdeleted = true
                        }
                    case "shortTitle":
                        currentEvent?.shorttitle = currentValue
                    default:
                        break
                    }
                }
            default:
                break
            }
        }
    }
    
    public func parse(url: URL ) {
        localManagedObjectContext = CoreDataBastard.sharedBastard.persistentContainer.viewContext
        let updateparser = XMLParser(contentsOf: url)
        updateparser!.delegate = self
        updateparser!.parse()
        print("update parsed")
        do {
            try localManagedObjectContext?.save()
        } catch {
            print ("context save failed")
        }
    }
}
