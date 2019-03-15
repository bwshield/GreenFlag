//
//  VenueDetailInterfaceController.swift
//  GreenFlagWatch Extension
//
//  Created by B Shield on 1/28/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class VenueDetailInterfaceController: WKInterfaceController {

    @IBOutlet weak var tableView: WKInterfaceTable!

    private var coreDataBastard = CoreDataBastard.sharedBastard
    private var fetchedResultController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    private var currentVenueAttributes : Array<VenueAttributes> = []
    private var currentVenue: Venues?
    private var rowTypes : [String] = []
    private var rowData : [Any?] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        currentVenue = context as? Venues
        currentVenueAttributes = currentVenue?.attributes?.allObjects as! [VenueAttributes]
        reloadEvents()        // Configure interface objects here.
        if currentVenueAttributes.count > 0 {
            rowTypes.append("VenueInfoHeaderRow")
            for _ in currentVenueAttributes {
                rowTypes.append("VenueInfoRow")
            }
        }
        let sections = fetchedResultController?.sections
        if sections!.count > 0 {
            rowTypes.append("VenueEventTopHeaderRow")
            for section in sections! {
                rowTypes.append("VenueEventHeaderRow")
                for _ in section.objects! {
                    rowTypes.append("VenueEventRow")
                }
            }
        }
        if coreDataBastard.venueMapInfo(venue: currentVenue!) != nil {
            rowTypes.append("VenueMapRow")
        }
        tableView.setRowTypes(rowTypes)
        var index = 0
        if currentVenueAttributes.count > 0 {
            let header = tableView.rowController(at: index) as! VenueInfoHeaderRow
            header.label.setText("Venue Info")
            rowData.append(nil)
            index += 1
            for attribute in currentVenueAttributes {
                let row = tableView.rowController(at: index) as! VenueInfoRow
                row.label.setText(attribute.attribute!)
                row.label2.setText(attribute.value!)
                //row.label.setText(String(format: "%@: %@", attribute.attribute!,attribute.value!))
                rowData.append(nil)
                index += 1
            }
        }
        if sections!.count > 0 {
            let header = tableView.rowController(at: index) as! VenueEventTopHeaderRow
            header.label1.setText("Venue Events")
            rowData.append(nil)
            index += 1
        }
        for section in sections! {
            let header = tableView.rowController(at: index) as! VenueEventHeaderRow
            header.label.setText(section.name)
            rowData.append(nil)
            index += 1
            let eventArray = section.objects as! [Events]
            for event in eventArray {
                let row = tableView.rowController(at: index) as! VenueEventRow
                row.label1.setText(event.series?.shortTitle!)
                row.label2.setText(event.shorttitle!)
                let (label3,_) = coreDataBastard.startDetailWatch(event: event)
                row.label3.setText(label3)
                rowData.append(event)
                index += 1
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
        if rowTypes[rowIndex] == "VenueMapRow" {
            let location = coreDataBastard.venueMapInfo(venue: currentVenue!)
            if location != nil {
                let region = MKCoordinateRegion(center: location!, latitudinalMeters: 2000.0, longitudinalMeters: 2000.0)
                return region
            }
        }
        return [ rowData[rowIndex],[rowData[rowIndex]]]
    }
    
    func reloadEvents() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "venue.venueID == %@", currentVenue!.venueID!)
        fetchRequest.predicate = predicate
        let managedObjectContext = coreDataBastard.persistentContainer.viewContext
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "eventMonth", cacheName: nil)
        do {
            try fetchedResultController?.performFetch()
        } catch {
            fatalError()
        }
    }

}
