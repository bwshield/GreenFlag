//
//  SeriesTabViewController.swift
//  GreenFlag
//
//  Created by Brian Shield on 1/13/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import UIKit
import CoreData

class SeriesTabViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    private let coreDataBastard = CoreDataBastard.sharedBastard
    private var seriesArray : Array<Series> = []
    private var fetchedResultController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        reloadSeries()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let selectedCell = tableView.indexPathForSelectedRow
        if selectedCell != nil {
            tableView.deselectRow(at: selectedCell!, animated: true)
        }
        if coreDataBastard.checkForUpdateFile() {
            coreDataBastard.parseUpdateFile()
            reloadSeries()
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        let sectioncount = (self.fetchedResultController?.sections?.count)!
        return sectioncount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = fetchedResultController?.sections!
        let sectionInfo = sections![section]
        let objectcount = sectionInfo.numberOfObjects
        return objectcount
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = fetchedResultController?.sections!
        let sectionInfo = sections![section]
        let sectionName = sectionInfo.name
        return sectionName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seriesTableCell", for: indexPath)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        let object = self.fetchedResultController?.object(at: indexPath)
        let rowData = object as! Series
        cell.textLabel?.text = rowData.title
        cell.detailTextLabel?.text = dateFormatter.string(from: rowData.startDate!).uppercased() + " thru " + dateFormatter.string(from: rowData.endDate!).uppercased()
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor(red: 0.0, green: 0.328125, blue: 0.574219, alpha: 1.0)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SeriesDetailSegue") {
            let destinationViewController = segue.destination as! SeriesDetailTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            let object = self.fetchedResultController?.object(at: indexPath)
            let rowData = object as! Series
            destinationViewController.setSeries(series: rowData)
        }
    }
    
    func reloadSeries() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Series")
        let sectionDescriptor = NSSortDescriptor(key: "section", ascending: true)
        let sortDescriptor = NSSortDescriptor(key: "sortorder", ascending: true)
        fetchRequest.sortDescriptors = [sectionDescriptor,sortDescriptor]
        let managedObjectContext = coreDataBastard.persistentContainer.viewContext
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath:"section", cacheName: nil)
        do {
            try fetchedResultController?.performFetch()
        } catch {
            fatalError()
        }
    }
}
