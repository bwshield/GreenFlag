//
//  VenueListInterfaceController.swift
//  GreenFlagWatch Extension
//
//  Created by B Shield on 1/28/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class VenueListInterfaceController: WKInterfaceController {

    @IBOutlet weak var tableView: WKInterfaceTable!
    
    private var coreDateBastard = CoreDataBastard.sharedBastard
    private var fetchedResultController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    private var rowData : [Any?] = []
    private var sortStyle = ""
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let sortStyleAttribute = coreDateBastard.getUserAttribute(attribute: "venuelistsortstyle")
        if sortStyleAttribute != nil {
            sortStyle = sortStyleAttribute!.value!
        } else {
            sortStyle = "alpha"
            coreDateBastard.setUserAttribute(attribute: "venuelistsortstyle", value: "alpha")
        }
        reloadVenues()
        reloadTable()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    public func setSortStyle(sortstyle: String) {
        self.sortStyle  = sortstyle
        coreDateBastard.setUserAttribute(attribute: "venuelistsortstyle", value: sortstyle)
        reloadVenues()
        reloadTable()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        if segueIdentifier == "VenueSortSegue" {
            return self
        }
        return nil
    }
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return rowData[rowIndex]
    }
    
    func reloadTable() {
        var rowTypes : [String] = []
        let sections = fetchedResultController?.sections
        for section in sections! {
            rowTypes.append("VenuesHeaderRow")
            for _ in section.objects! {
                rowTypes.append("VenuesRow")
            }
        }
        tableView.setRowTypes(rowTypes)
        var index = 0
        for section in sections! {
            let header = tableView.rowController(at: index) as! VenuesHeaderRow
            header.label.setText(section.name)
            rowData.append(nil)
            index += 1
            let venueArray = section.objects as! [Venues]
            for venue in venueArray {
                let row = tableView.rowController(at: index) as! VenuesRow
                row.label.setText(venue.shorttitle)
                rowData.append(venue)
                index += 1
            }
        }
    }
    func reloadVenues() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Venues")
        var sortDescriptors : [NSSortDescriptor] = []
        if sortStyle == "alpha" {
            let alphaDescriptor = NSSortDescriptor(key: "shorttitle", ascending: true)
            sortDescriptors.append(alphaDescriptor)
        } else {
            let continentDescriptor = NSSortDescriptor(key: "continent", ascending: true)       // *** can not use transient attribute to sort, but can use for sectionKeyPath
            sortDescriptors.append(continentDescriptor)
        }
        let titleDescriptor = NSSortDescriptor(key: "title", ascending: true)
        sortDescriptors.append(titleDescriptor)
        fetchRequest.sortDescriptors = sortDescriptors
        let managedObjectContext = CoreDataBastard.sharedBastard.persistentContainer.viewContext
        if sortStyle == "alpha" {
            fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "alphasort", cacheName: nil)
        } else {
            fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "continent", cacheName: nil)
        }
        do {
            try fetchedResultController?.performFetch()
        } catch {
            fatalError()
        }
    }
}
