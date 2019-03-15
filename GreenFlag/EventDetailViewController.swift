//
//  EventDetailViewController.swift
//  GreenFlag
//
//  Created by Brian Shield on 1/16/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var eventsArray : Array<Events> = []
    private var excludedEventsArray : Array<Events> = []
    private var currentEvent : Events? = nil
    private var currentEventAttributes : Array<EventAttributes> = []
    private var currentVenueAttributes : Array<VenueAttributes> = []
    private var coreDataBastard = CoreDataBastard.sharedBastard
    private var fetchedResultController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //if coreDataBastard.checkForUpdateFile() {
           // self.navigationController?.popToRootViewController(animated: false)
        //}
        reloadEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let selectedCell = tableView.indexPathForSelectedRow
        if selectedCell != nil {
            tableView.deselectRow(at: selectedCell!, animated: true)
        }
    }
    
    public func setEvent(event: Events) {
        currentEvent = event
        currentEventAttributes = currentEvent?.attributes?.allObjects as! [EventAttributes]
        currentVenueAttributes = currentEvent?.venue?.attributes?.allObjects as! [VenueAttributes]
        if coreDataBastard.venueMapInfo(venue: currentEvent!.venue!) != nil {
            self.navigationItem.rightBarButtonItem = mapButton
        }
        //reloadEvents()
    }
    public func setExcludedEvents(exclude: [Events]) {
        excludedEventsArray = exclude
    }
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        var sectioncount = (self.fetchedResultController?.sections?.count)!
        if sectioncount == 0 {
            sectioncount += 1
        } else {
            sectioncount += 2
        }
        //if currentVenueAttributes.count > 0 {
            sectioncount += 1
        //}
        return sectioncount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var eventsection = section - 1
        if currentVenueAttributes.count > 0 {
            eventsection -= 1
        }
        if section == 0 {
            if currentEventAttributes.count == 0 {
                return 1
            }
            return currentEventAttributes.count + 1
        }
        if section == 1 {
        //if currentVenueAttributes.count > 0  && section == 1 {
            if currentVenueAttributes.count > 0 {
                return currentVenueAttributes.count + 1
            } else {
                return 1
            }
        }
        if eventsection == 0 {
            return 0
        }
        let row = eventsection - 1
        let sections = fetchedResultController?.sections!
        let sectionInfo = sections![row]
        let objectcount = sectionInfo.numberOfObjects
        return objectcount
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var eventsection = section - 1
        if currentVenueAttributes.count > 0 {
            eventsection -= 1
        }
        if section == 0 {
            return "Event Info"
        }
        //if currentVenueAttributes.count > 0 && section == 1 {
        if section == 1 {
        return "Venue Info"
        }
        if eventsection == 0 {
            return "Additional Venue Events"
        }
        eventsection -= 1
        let sections = fetchedResultController?.sections!
        let sectionInfo = sections![eventsection]
        return sectionInfo.name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var eventIndexPath = indexPath
        eventIndexPath.section -= 2
        //if currentVenueAttributes.count > 0 {
            eventIndexPath.section -= 1
        //}
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventDetailCell", for: indexPath)
                cell.textLabel?.text = currentEvent?.title
                let detailText = coreDataBastard.startDetailLong(event: currentEvent!)
                cell.detailTextLabel?.text = detailText
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventDetailAttributeCell", for: indexPath)
            let attribute = currentEventAttributes[indexPath.row - 1]
            let cellText = attribute.attribute! + ": " + attribute.value!
            cell.textLabel?.text = cellText
            return cell
        }
        //if currentVenueAttributes.count > 0 && indexPath.section == 1 {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EventDetailAttributeCell", for: indexPath)
                cell.textLabel?.text = "Name: " + currentEvent!.venue!.title!
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventDetailAttributeCell", for: indexPath)
            let attribute = currentVenueAttributes[indexPath.row - 1]
            let cellText = attribute.attribute! + ": " + attribute.value!
            cell.textLabel?.text = cellText
            return cell
        }
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventDetailCell", for: indexPath)
        let object = self.fetchedResultController?.object(at: eventIndexPath)
        let rowData = object as! Events
        cell.textLabel?.text = rowData.title! + " [" + rowData.series!.shortTitle! + "]"
        let detailText = coreDataBastard.startDetailLong(event: rowData)
        cell.detailTextLabel?.text = detailText
        if excludedEventsArray.contains(rowData) {
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var eventIndexPath = indexPath
        eventIndexPath.section -= 2
        if indexPath.section == 0 && indexPath.row == 0 {
            return nil
        }
        //if currentVenueAttributes.count > 0 {
            eventIndexPath.section -= 1
        //}
        //if currentVenueAttributes.count > 0 && indexPath.section == 1 {
        if indexPath.section == 1 {
            return nil
        }
        let object = self.fetchedResultController?.object(at: eventIndexPath)
        let rowData = object as! Events
        if excludedEventsArray.contains(rowData) {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        var headerColor : UIColor?
        var eventsection = section - 1
        //if currentVenueAttributes.count > 0 {
            eventsection -= 1
        //}
        if section == 0 {
            headerColor = UIColor(red: 0.0, green: 0.5625, blue: 0.316406, alpha: 1.0)
        } else if currentVenueAttributes.count > 0 && section == 1 {
            headerColor = UIColor(red: 0.578125, green: 0.066406, blue: 0.0, alpha: 1.0)
        } else if eventsection == 0 {
            headerColor = UIColor(red: 0.488281, green: 0.273438, blue: 0.0, alpha: 1.0)
        } else {
            headerColor = UIColor(red: 0.578125, green: 0.320313, blue: 0.0, alpha: 1.0)
        }
        
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = headerColor
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventEventDetailSegue" {
            var indexPath = self.tableView.indexPathForSelectedRow!
            indexPath.section -= 2
            //if currentVenueAttributes.count > 0 {
                indexPath.section -= 1
            //}
            let object = self.fetchedResultController?.object(at: indexPath)
            let rowData = object as! Events
            var newExcludedEventsArray = excludedEventsArray
            newExcludedEventsArray.append(rowData)
            //excludedEventsArray.append(selectedEvent)
            let destinationViewController = segue.destination as! EventDetailViewController
            //destinationViewController.setManagedObjectContext(managedObjectContext: managedObjectContext!)
            destinationViewController.setExcludedEvents(exclude: newExcludedEventsArray)
            //currentEvent = selectedEvent
            destinationViewController.setEvent(event: rowData)
        } else if segue.identifier == "EventMapSegue" {
            let destinationViewController = segue.destination as! VenueMapViewController
            let location = coreDataBastard.venueMapInfo(venue: currentEvent!.venue!)
            if location != nil {
                let region = MKCoordinateRegion(center: location!, latitudinalMeters: 2000.0, longitudinalMeters: 2000.0)
                destinationViewController.setMapInfo(center: location, region: region, name: currentEvent!.venue!.title)
            }
        }
    }
 
    func reloadEvents() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let venueID = currentEvent?.venue?.venueID
        let predicate = NSPredicate(format: "venue.venueID == %@ AND eventID != %@", venueID!,(currentEvent?.eventID)!)
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
