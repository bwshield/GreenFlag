//
//  SeriesListInterfaceController.swift
//  GreenFlagWatch Extension
//
//  Created by B Shield on 1/28/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import WatchKit
import Foundation
import CoreData

class SeriesListInterfaceController: WKInterfaceController {

    @IBOutlet weak var tableView: WKInterfaceTable!
    
    private var fetchedResultController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    private var rowData : [Any?] = []
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        reloadSeries()
        
        var rowTypes : [String] = []
        let sections = fetchedResultController?.sections
        for section in sections! {
            rowTypes.append("SeriesListHeaderRow")
            for _ in section.objects! {
                rowTypes.append("SeriesListRow")
            }
        }
        tableView.setRowTypes(rowTypes)
        var index = 0
        for section in sections! {
            let header = tableView.rowController(at: index) as! SeriesListHeaderRow
            header.label.setText(section.name)
            rowData.append(nil)
            index += 1
            let seriesArray = section.objects as! [Series]
            for series in seriesArray {
                let row = tableView.rowController(at: index) as! SeriesListRow
                row.label.setText(series.shortTitle)
                rowData.append(series)
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
        return rowData[rowIndex]
    }
    func reloadSeries() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Series")
        let sectionDescriptor = NSSortDescriptor(key: "section", ascending: true)
        let sortDescriptor = NSSortDescriptor(key: "sortorder", ascending: true)
        fetchRequest.sortDescriptors = [sectionDescriptor,sortDescriptor]
        let managedObjectContext = CoreDataBastard.sharedBastard.persistentContainer.viewContext
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath:"section", cacheName: nil)
        do {
            try fetchedResultController?.performFetch()
        } catch {
            fatalError()
        }
    }
}
