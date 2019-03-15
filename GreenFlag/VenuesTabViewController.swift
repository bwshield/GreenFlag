//
//  VenuesTabViewController.swift
//  GreenFlag
//
//  Created by Brian Shield on 1/13/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import UIKit
import CoreData

class VenuesTabViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    private var venuesArray : Array<Venues> = []
    private var fetchedResultController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    private var sectionIndexArray : Array<String> = []
    private var sortStyle : String = "alpha"
    private let coreDataBastard = CoreDataBastard.sharedBastard
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentationControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sortStyleAttribute = coreDataBastard.getUserAttribute(attribute: "venuelistsortstyle")
        if sortStyleAttribute != nil {
            switch sortStyleAttribute?.value {
            case "alpha":
                sortStyle = "alpha"
                sortSegmentationControl.selectedSegmentIndex = 0
            default:
                sortStyle = "continent"
                sortSegmentationControl.selectedSegmentIndex = 1
            }
        } else {
            sortStyle = "alpha"
            coreDataBastard.setUserAttribute(attribute: "venuelistsortstyle", value: sortStyle)
        }
        reloadVenues()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let selectedCell = tableView.indexPathForSelectedRow
        if selectedCell != nil {
            tableView.deselectRow(at: selectedCell!, animated: true)
        }
        if coreDataBastard.checkForUpdateFile() {
            coreDataBastard.parseUpdateFile()
            reloadVenues()
            tableView.reloadData()
        }
    }
    /*
    public func setSortStyle(sortStyle: String) {
        self.sortStyle = sortStyle
        reloadVenues()
        tableView.reloadData()
    }
    */
    @IBAction func venuesSegmentationControlChanged(_ sender: Any) {
        switch sortSegmentationControl.selectedSegmentIndex {
        case 0:
            sortStyle = "alpha"
        default:
            sortStyle = "continent"
        }
        coreDataBastard.setUserAttribute(attribute: "venuelistsortstyle", value: sortStyle)
        reloadVenues()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        let sectioncount = (self.fetchedResultController?.sections?.count)!
        return sectioncount
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexArray
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
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
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor(red: 0.578125, green: 0.066406, blue: 0.0, alpha: 1.0)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "venuesTableCell", for: indexPath)
        let object = self.fetchedResultController?.object(at: indexPath)
        let rowData = object as! Venues
        cell.textLabel?.text = rowData.title
        return cell
    }
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "VenueDetailSegue") {
            let destinationViewController = segue.destination as! VenueDetailViewController
            //destinationViewController.setManagedObjectContext(managedObjectContext: managedObjectContext!)
            let indexPath = self.tableView.indexPathForSelectedRow!
            let object = self.fetchedResultController?.object(at: indexPath)
            let rowData = object as! Venues
            destinationViewController.setVenue(venue: rowData)
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
        let managedObjectContext = coreDataBastard.persistentContainer.viewContext
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
        sectionIndexArray = []
        let sections = fetchedResultController?.sections!
        for section in sections! {
            let name = section.name
            switch sortStyle {
            case "alpha":
                let firststring = String(name.first!)
                sectionIndexArray.append(firststring)
            default:
                switch name {
                case "Africa":
                    sectionIndexArray.append("AF")
                case "Antartica":
                    sectionIndexArray.append("AN")
                case "Asia":
                    sectionIndexArray.append("AS")
                case "Europe":
                    sectionIndexArray.append("EU")
                case "North America":
                    sectionIndexArray.append("NA")
                case "Oceania":
                    sectionIndexArray.append("OC")
                case "South America":
                    sectionIndexArray.append("SA")
                default:
                    sectionIndexArray.append("SA")
                }
            }
        }
    }

}
