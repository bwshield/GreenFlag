//
//  SeriesEventListInterfaceController.swift
//  GreenFlagWatch Extension
//
//  Created by B Shield on 1/28/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class SeriesEventListInterfaceController: WKInterfaceController {

    @IBOutlet weak var seriesEventsTable: WKInterfaceTable!

    private var coreDataBastard = CoreDataBastard.sharedBastard
    private var fetchedResultController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    private var currentSeriesAttributes : Array<SeriesAttributes> = []
    private var currentSeries: Series?
    private var rowData : [Any?] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        currentSeries = context as? Series
        currentSeriesAttributes = currentSeries?.attributes?.allObjects as! [SeriesAttributes]
        reloadEvents()        // Configure interface objects here.
        var rowTypes : [String] = []
        if currentSeriesAttributes.count > 0 {
            rowTypes.append("SeriesInfoHeaderRow")
            for _ in currentSeriesAttributes {
                rowTypes.append("SeriesInfoRow")
                }
        }
        let sections = fetchedResultController?.sections
        for section in sections! {
            rowTypes.append("SeriesEventHeaderRow")
            for _ in section.objects! {
                rowTypes.append("SeriesEventsRow")
                }
        }
        seriesEventsTable.setRowTypes(rowTypes)
        var index = 0
        if currentSeriesAttributes.count > 0 {
            let header = seriesEventsTable.rowController(at: index) as! SeriesInfoHeaderRow
            header.label.setText("Series Info")
            rowData.append(nil)
            index += 1
            for attribute in currentSeriesAttributes {
                let row = seriesEventsTable.rowController(at: index) as! SeriesInfoRow
                row.label.setText(attribute.attribute!)
                row.label2.setText(attribute.value!)
                //row.label.setText(String(format: "%@: %@", attribute.attribute!,attribute.value!))
                rowData.append(nil)
                index += 1
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        for section in sections! {
            let header = seriesEventsTable.rowController(at: index) as! SeriesEventHeaderRow
            header.label.setText(section.name)
            rowData.append(nil)
            index += 1
            let eventArray = section.objects as! [Events]
            for event in eventArray {
                let row = seriesEventsTable.rowController(at: index) as! SeriesEventsRow
                row.label1.setText(event.shorttitle)
                let (label2,_) = coreDataBastard.startDetailWatch(event: event)
                row.label2.setText(label2)
                //row.label3.setText(label3)
                rowData.append(event)
                index += 1
            }
        }
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
        return [ rowData[rowIndex],[rowData[rowIndex]]]
    }
    
    func reloadEvents() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "series.seriesID == %@", currentSeries!.seriesID!)
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
