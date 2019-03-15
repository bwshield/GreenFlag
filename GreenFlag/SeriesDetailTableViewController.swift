//
//  SeriesDetailTableViewController.swift
//  GreenFlag
//
//  Created by Brian Shield on 1/16/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import UIKit
import CoreData

class SeriesDetailTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var currentSeries : Series? = nil
    private var currentSeriesAttributes : Array<SeriesAttributes> = []
    private var pastEvents : Bool = true
    private var coreDataBastard = CoreDataBastard.sharedBastard
    private var fetchedResultController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    
    @IBOutlet weak var pastEventsSwitch: UISwitch!
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // if coreDataBastard.checkForUpdateFile() {
            //coreDataBastard.parseUpdateFile()
           // self.navigationController?.popToRootViewController(animated: false)
        //}
        
        let pastEventsAttribute = coreDataBastard.getUserAttribute(attribute: "seriespastevents")
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
            coreDataBastard.setUserAttribute(attribute: "seriespastevents", value: "1")
        }
        reloadEvents()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let selectedCell = tableView.indexPathForSelectedRow
        if selectedCell != nil {
            tableView.deselectRow(at: selectedCell!, animated: true)
        }
    }
    
    public func setSeries(series: Series) {
        currentSeries = series
        currentSeriesAttributes = currentSeries?.attributes?.allObjects as! [SeriesAttributes]
        //reloadEvents()
    }
   
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        var sectioncount = (self.fetchedResultController?.sections?.count)!
        //if currentSeriesAttributes.count > 0 {
            sectioncount += 1
        //}
        return sectioncount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var eventsection = section
        //if currentSeriesAttributes.count > 0 {
            if section == 0 {
                return currentSeriesAttributes.count + 1
            }
            eventsection -= 1
       // }
        let row = eventsection
        let sections = fetchedResultController?.sections!
        let sectionInfo = sections![row]
        let objectcount = sectionInfo.numberOfObjects
        return objectcount
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var eventsection = section
        //if currentSeriesAttributes.count > 0 {
            if section == 0 {
                return "Series Info"
            }
            eventsection -= 1
        //}
        let sections = fetchedResultController?.sections!
        let sectionInfo = sections![eventsection]
        let sectionName = sectionInfo.name
        return sectionName
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var eventsection = indexPath.section
        //if currentSeriesAttributes.count > 0 {
            if eventsection == 0 {
                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "seriesEventsAttributesTableCell", for: indexPath)
                    cell.textLabel?.text = "Series: " + currentSeries!.title!
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "seriesEventsAttributesTableCell", for: indexPath)
                    let attribute = currentSeriesAttributes[indexPath.row - 1]
                    let cellText = attribute.attribute! + ": " + attribute.value!
                    cell.textLabel?.text = cellText
                    return cell
                }
            } else {
                eventsection -= 1
            }
        //}
        let cell = tableView.dequeueReusableCell(withIdentifier: "seriesEventsTableCell", for: indexPath)
        var eventIndexPath = indexPath
        //if currentSeriesAttributes.count > 0 {
            eventIndexPath.section -= 1
        //}
        let object = self.fetchedResultController?.object(at: eventIndexPath)
        let rowData = object as! Events
        cell.textLabel?.text = rowData.title
        let detailText = coreDataBastard.startDetailLong(event: rowData)
        cell.detailTextLabel?.text = detailText
        return cell
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if currentSeriesAttributes.count > 0  && indexPath.section == 0 {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        var headerColor : UIColor?
        //if currentSeriesAttributes.count > 0 && section == 0 {
        if section == 0 {
                headerColor = UIColor(red: 0.0, green: 0.328125, blue: 0.574219, alpha: 1.0)
        } else {
            headerColor = UIColor(red: 0.0, green: 0.5625, blue: 0.316406, alpha: 1.0)
        }
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = headerColor
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
    
    @IBAction func pastEventSwitchChanged(_ sender: Any) {
        switch pastEventsSwitch.isOn {
        case true:
            pastEvents = true
            coreDataBastard.setUserAttribute(attribute: "seriespastevents", value: "1")
        default:
            pastEvents = false
            coreDataBastard.setUserAttribute(attribute: "seriespastevents", value: "0")
        }
        reloadEvents()
        self.tableView.reloadData()
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SeriesEventDetailSegue" {
            let destinationViewController = segue.destination as! EventDetailViewController
            var indexPath = self.tableView.indexPathForSelectedRow!
            //if currentSeriesAttributes.count > 0 {
                indexPath.section -= 1
            //}
            let object = self.fetchedResultController?.object(at: indexPath)
            let rowData = object as! Events
            destinationViewController.setEvent(event: rowData)
            destinationViewController.setExcludedEvents(exclude: [rowData])
            }
        }

    func reloadEvents() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        var predicate : NSPredicate?
        if pastEvents {
            predicate = NSPredicate(format: "series.seriesID == %@", currentSeries!.seriesID!)
        } else {
            predicate = NSPredicate(format: "series.seriesID == %@ AND endDate >= %@", currentSeries!.seriesID!, Date() as NSDate)
        }
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
