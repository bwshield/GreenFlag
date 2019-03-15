//
//  EventsTabViewController.swift
//  GreenFlag
//
//  Created by Brian Shield on 1/13/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import UIKit
import CoreData

class EventsTabViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate {

    private var eventsArray : Array<Events> = []
    private var coreDataBastard = CoreDataBastard.sharedBastard
    private var fetchedResultController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    private var sectionIndexArray : Array<String> = []
    private var sortStyle : String = "alpha"
    private var pastEvents : Bool = true
    
    @IBOutlet weak var pastEventsSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentationControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sortStyleAttribute = coreDataBastard.getUserAttribute(attribute: "eventlistsortstyle")
        if sortStyleAttribute != nil {
            switch sortStyleAttribute?.value {
            case "date":
                sortStyle = "date"
                sortSegmentationControl.selectedSegmentIndex = 0
            case "series":
                sortStyle = "series"
                sortSegmentationControl.selectedSegmentIndex = 1
            default:
                sortStyle = "continent"
                sortSegmentationControl.selectedSegmentIndex = 2
            }
        } else {
            sortStyle = "date"
            coreDataBastard.setUserAttribute(attribute: "eventlistsortstyle", value: sortStyle)
        }
        let pastEventsAttribute = coreDataBastard.getUserAttribute(attribute: "eventpastevents")
        if pastEventsAttribute != nil {
            switch pastEventsAttribute?.value {
            case "1":
                pastEvents = true
                pastEventsSwitch.isOn = true
            default:
                pastEvents = false
                pastEventsSwitch.isOn = false
            }
        } else {
            pastEvents = true
            pastEventsSwitch.isOn = true
            coreDataBastard.setUserAttribute(attribute: "eventpastevents", value: "1")
        }
        
        reloadEvents()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let selectedCell = tableView.indexPathForSelectedRow
        if selectedCell != nil {
            tableView.deselectRow(at: selectedCell!, animated: true)
        }
        if coreDataBastard.checkForUpdateFile() {
            coreDataBastard.parseUpdateFile()
            reloadEvents()
            tableView.reloadData()
        }
    }
    /*
    public func setSortStyle(sortStyle: String) {
        self.sortStyle = sortStyle
        reloadEvents()
        tableView.reloadData()
    }
    */
    @IBAction func eventsSortSegmentationControlChanged(_ sender: Any) {
        switch sortSegmentationControl.selectedSegmentIndex {
        case 0:
            sortStyle = "date"
        case 1:
            sortStyle = "series"
        default:
            sortStyle = "continent"
        }
        coreDataBastard.setUserAttribute(attribute: "eventlistsortstyle", value: sortStyle)
        reloadEvents()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventsTableCell", for: indexPath)
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-dd"
        let object = self.fetchedResultController?.object(at: indexPath)
        let rowData = object as! Events
        if sortStyle == "series" {
            cell.textLabel?.text = rowData.title
        } else {
            cell.textLabel?.text = rowData.title! + " [" + rowData.series!.shortTitle! + "]"
        }
        let detailText = coreDataBastard.startDetailLong(event: rowData)
        cell.detailTextLabel?.text = detailText
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor(red: 0.0, green: 0.5625, blue: 0.316406, alpha: 1.0)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
    @IBAction func pastEventSwitchChanged(_ sender: Any) {
        switch pastEventsSwitch.isOn {
        case true:
            pastEvents = true
            coreDataBastard.setUserAttribute(attribute: "eventpastevents", value: "1")
        default:
            pastEvents = false
            coreDataBastard.setUserAttribute(attribute: "eventpastevents", value: "0")
        }
        reloadEvents()
        self.tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EventDetailSegue") {
            let destinationViewController = segue.destination as! EventDetailViewController
            //destinationViewController.setManagedObjectContext(managedObjectContext: managedObjectContext!)
            let indexPath = self.tableView.indexPathForSelectedRow!
            let object = self.fetchedResultController?.object(at: indexPath)
            let rowData = object as! Events
            //let currentEvent = eventsArray[indexPath.row]
            destinationViewController.setEvent(event: rowData)
            destinationViewController.setExcludedEvents(exclude: [rowData])
        }
    }
    
    func reloadEvents() {
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
        if !pastEvents {
            let predicate = NSPredicate(format: "endDate >= %@", Date() as NSDate)
            fetchRequest.predicate = predicate
        }
        if sortStyle == "series" {
            sectionNameKeyPath = "series.title"
        } else if sortStyle == "continent" {
            sectionNameKeyPath = "venue.continent"
        }
        let managedObjectContext = coreDataBastard.persistentContainer.viewContext
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
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
            case "series":
                let firstSectionEvent = section.objects?.first as! Events
                let seriesShortTitle = firstSectionEvent.series?.shortTitle
                sectionIndexArray.append(seriesShortTitle!)
            case "continent":
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
            default:
                switch name {
                case "January":
                    sectionIndexArray.append("JAN")
                case "February":
                    sectionIndexArray.append("FEB")
                case "March":
                    sectionIndexArray.append("MAR")
                case "April":
                    sectionIndexArray.append("APR")
                case "May":
                    sectionIndexArray.append("MAY")
                case "June":
                    sectionIndexArray.append("JUN")
                case "July":
                    sectionIndexArray.append("JUL")
                case "August":
                    sectionIndexArray.append("AUG")
                case "September":
                    sectionIndexArray.append("SEP")
                case "October":
                    sectionIndexArray.append("OCT")
                case "November":
                    sectionIndexArray.append("NOV")
                default:
                    sectionIndexArray.append("DEC")
                    
                }
            }
        }
    }
}
