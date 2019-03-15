//
//  EventListInterfaceController.swift
//  GreenFlagWatch Extension
//
//  Created by B Shield on 1/28/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import WatchKit
import Foundation
import CoreData


class EventListInterfaceController: WKInterfaceController {

    @IBOutlet weak var tableView: WKInterfaceTable!
    
    private var coreDateBastard = CoreDataBastard.sharedBastard
    private var fetchedResultController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    private var rowData : [Any?] = []
    private var sortStyle = ""
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let sortStyleAttribute = coreDateBastard.getUserAttribute(attribute: "eventlistsortstyle")
        if sortStyleAttribute != nil {
            sortStyle = sortStyleAttribute!.value!
        } else {
            sortStyle = "date"
            coreDateBastard.setUserAttribute(attribute: "eventlistsortstyle", value: "date")
        }
        reloadEvents()
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
        coreDateBastard.setUserAttribute(attribute: "eventlistsortstyle", value: sortstyle)
        reloadEvents()
        reloadTable()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        if segueIdentifier == "EventSortSegue" {
            return self
        }
        return nil
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable,
        rowIndex: Int) -> Any? {
        return [ rowData[rowIndex],[rowData[rowIndex]]]
    }
    func reloadTable() {
        var rowTypes : [String] = []
        let sections = fetchedResultController?.sections
        for section in sections! {
            rowTypes.append("EventsHeaderRow")
            for _ in section.objects! {
                rowTypes.append("EventsRow")
            }
        }
        tableView.setRowTypes(rowTypes)
        var index = 0
        for section in sections! {
            let header = tableView.rowController(at: index) as! EventsHeaderRow
            header.label.setText(section.name)
            rowData.append(nil)
            index += 1
            let eventArray = section.objects as! [Events]
            for event in eventArray {
                let row = tableView.rowController(at: index) as! EventsRow
                if sortStyle == "series" {
                    row.label1.setText("")
                } else {
                    row.label1.setText(event.series?.shortTitle)
                }
                row.label2.setText(event.shorttitle)
                let (label3,_) = coreDateBastard.startDetailWatch(event: event)
                row.label3.setText(label3)
                rowData.append(event)
                index += 1
            }
        }
    }
    func reloadEvents() {
        //let sortStyle = "alpha"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        var sortDescriptors : [NSSortDescriptor] = []
        var sectionNameKeyPath : String = "eventMonth"
        if sortStyle == "series" {
            let seriesDescriptor = NSSortDescriptor(key: "series.title", ascending: true)
            sortDescriptors.append(seriesDescriptor)
        } else if sortStyle == "continent" {
            let continentDescriptor = NSSortDescriptor(key: "venue.continent", ascending: true)
            sortDescriptors.append(continentDescriptor)
        }
        let dateDescriptor = NSSortDescriptor(key: "endDate", ascending: true)
        sortDescriptors.append(dateDescriptor)
        fetchRequest.sortDescriptors = sortDescriptors
        if sortStyle == "series" {
            sectionNameKeyPath = "series.title"
        } else if sortStyle == "continent" {
            sectionNameKeyPath = "venue.continent"
        }
        let managedObjectContext = coreDateBastard.persistentContainer.viewContext
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        do {
            try fetchedResultController?.performFetch()
        } catch {
            fatalError()
        }
    }
}
