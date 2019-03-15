//
//  EventDetailInterfaceController.swift
//  GreenFlagWatch Extension
//
//  Created by B Shield on 1/28/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class EventDetailInterfaceController: WKInterfaceController {

    @IBOutlet weak var tableView: WKInterfaceTable!
    
    private var coreDataBastard = CoreDataBastard.sharedBastard
    private var fetchedResultController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    private var currentEventAttributes : Array<EventAttributes> = []
    private var currentEvent: Events?
    private var excludedEventsArray : Array<Events> = []
    private var currentVenueAttributes : Array<VenueAttributes> = []
    private var rowTypes : [String] = []
    private var rowData : [Any?] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let contextArray  = context as! Array<Any>
        currentEvent = (contextArray[0] as! Events)
        excludedEventsArray = contextArray[1] as! [Events]
        currentEventAttributes = currentEvent?.attributes?.allObjects as! [EventAttributes]
        currentVenueAttributes = currentEvent?.venue?.attributes?.allObjects as! [VenueAttributes]
        reloadEvents()        // Configure interface objects here.
        rowTypes.append("EventInfoHeaderRow")
        rowTypes.append("CurrentEventRow")
        if currentEventAttributes.count > 0 {
            for _ in currentEventAttributes {
                rowTypes.append("EventInfoRow")
            }
        }
        if currentVenueAttributes.count > 0 {
            rowTypes.append("EventVenueHeaderRow")
            for _ in currentVenueAttributes {
                rowTypes.append("EventVenueInfoRow")
            }
        }
        let sections = fetchedResultController?.sections
        if sections!.count > 0 {
            rowTypes.append("OtherEventTopHeaderRow")
            for section in sections! {
                rowTypes.append("OtherEventsHeaderRow")
                for event in section.objects! {
                    if excludedEventsArray.contains(event as! Events) {
                        rowTypes.append("OtherEventExcludedRow")
                    } else {
                        rowTypes.append("OtherEventRow")
                    }
                }
            }
        }
        if coreDataBastard.venueMapInfo(venue: currentEvent!.venue!) != nil {
            rowTypes.append("EventDetailMapRow")
        }
        tableView.setRowTypes(rowTypes)
        var index = 0
        let header = tableView.rowController(at: index) as! EventInfoHeaderRow
        header.label.setText("Event Info")
        rowData.append(nil)
        index += 1
        let row = tableView.rowController(at: index) as! CurrentEventRow
        row.label1.setText(currentEvent?.shorttitle!)
        let (label2,label3) = coreDataBastard.startDetailWatch(event: currentEvent!)
        row.label2.setText(label2)
        row.label3.setText(label3)
        rowData.append(nil)
        index += 1
        if currentEventAttributes.count > 0 {
           for attribute in currentEventAttributes {
                let row = tableView.rowController(at: index) as! EventInfoRow
                row.label.setText(attribute.attribute!)
                row.label2.setText(attribute.value!)
                //row.label.setText(String(format: "%@: %@", attribute.attribute!,attribute.value!))
                rowData.append(nil)
                index += 1
            }
        }
        if currentVenueAttributes.count > 0 {
           let header = tableView.rowController(at: index) as! EventVenueHeaderRow
            header.label.setText("Venue Info")
            rowData.append(nil)
            index += 1
            for attribute in currentVenueAttributes {
                let row = tableView.rowController(at: index) as! EventVenueInfoRow
                row.label.setText(attribute.attribute!)
                row.label2.setText(attribute.value!)
                //row.label.setText(String(format: "%@: %@", attribute.attribute!,attribute.value!))
                rowData.append(nil)
                index += 1
            }
        }
        if sections!.count > 0 {
            let header = tableView.rowController(at: index) as! OtherEventTopHeaderRow
            header.label1.setText("Additional")
            header.label2.setText("Venue Events")
            rowData.append(nil)
            index += 1
            for section in sections! {
                let header = tableView.rowController(at: index) as! OtherEventsHeaderRow
                header.label.setText(section.name)
                rowData.append(nil)
                index += 1
                let eventArray = section.objects as! [Events]
                for event in eventArray {
                    let label1text = event.series?.shortTitle!
                    let label2text = event.shorttitle!
                    let (label3,_) = coreDataBastard.startDetailWatch(event: event)
                    if excludedEventsArray.contains(event) {
                        let row = tableView.rowController(at: index) as! OtherEventExcludedRow
                        row.label1.setText(label1text)
                        row.label2.setText(label2text)
                        row.label3.setText(label3)
                    } else {
                        let row = tableView.rowController(at: index) as! OtherEventRow
                        row.label1.setText(label1text)
                        row.label2.setText(label2text)
                        row.label3.setText(label3)
                    }
                    rowData.append(event)
                    index += 1
                }
            }
        }
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        if rowTypes[rowIndex] == "EventDetailMapRow" {
            let location = coreDataBastard.venueMapInfo(venue: currentEvent!.venue!)
            if location != nil {
                let region = MKCoordinateRegion(center: location!, latitudinalMeters: 2000.0, longitudinalMeters: 2000.0)
                return region
            }
        }
        excludedEventsArray.append(rowData[rowIndex] as! Events)
        return [ rowData[rowIndex],excludedEventsArray]
    }
    
    func reloadEvents() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let venueID = currentEvent?.venue?.venueID
        let predicate = NSPredicate(format: "venue.venueID == %@ AND eventID != %@", venueID!,(currentEvent?.eventID)!)
        fetchRequest.predicate = predicate
        let managedObjectContext = CoreDataBastard.sharedBastard.persistentContainer.viewContext
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "eventMonth", cacheName: nil)
        do {
            try fetchedResultController?.performFetch()
        } catch {
            fatalError()
        }
    }
}
