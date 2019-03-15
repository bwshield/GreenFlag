//
//  VenueDetailViewController.swift
//  GreenFlag
//
//  Created by Brian Shield on 1/16/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class VenueDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //private var managedObjectContext: NSManagedObjectContext? = nil
    private var eventsArray : Array<Events> = []
    private var currentVenue : Venues? = nil
    private var currentVenueAttributes : Array<VenueAttributes> = []
    private var coreDataBastard = CoreDataBastard.sharedBastard
    private var fetchedResultController : NSFetchedResultsController<NSFetchRequestResult>? = nil
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var mapButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //if coreDataBastard.checkForUpdateFile() {
            //coreDataBastard.parseUpdateFile()
            //self.navigationController?.popToRootViewController(animated: false)
       // }
        reloadEvents()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let selectedCell = tableView.indexPathForSelectedRow
        if selectedCell != nil {
            tableView.deselectRow(at: selectedCell!, animated: true)
        }
    }
   
    public func setVenue(venue: Venues) {
        currentVenue = venue
        currentVenueAttributes = currentVenue?.attributes?.allObjects as! [VenueAttributes]
        if coreDataBastard.venueMapInfo(venue: currentVenue!) != nil {
            self.navigationItem.rightBarButtonItem = mapButton
        }
        //reloadEvents()
    }
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        var sectioncount = (self.fetchedResultController?.sections?.count)!
        sectioncount += 1
        //if currentVenueAttributes.count > 0 {
            sectioncount += 1
        //}
        return sectioncount
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var eventsection = section
        //if currentVenueAttributes.count > 0 {
            if section == 0 {
                return currentVenueAttributes.count + 1
            }
            eventsection -= 1
        //}
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
        var eventsection = section
        //if currentVenueAttributes.count > 0 {
            if section == 0 {
                return "Venue Info"
            }
            eventsection -= 1
        //}
        if eventsection == 0 {
            return "Venue Events"
        }
        eventsection -= 1
        let sections = fetchedResultController?.sections!
        let sectionInfo = sections![eventsection]
        let sectionName = sectionInfo.name
        return sectionName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var eventsection = indexPath.section
        //eventsection -= 1
        //if currentVenueAttributes.count > 0 {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "venueEventsAttributeTableCell", for: indexPath)
                    cell.textLabel?.text = "Name: " + currentVenue!.title!
                    return cell
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "venueEventsAttributeTableCell", for: indexPath)
                let attribute = currentVenueAttributes[indexPath.row - 1]
                let cellText = attribute.attribute! + ": " + attribute.value!
                cell.textLabel?.text = cellText
                return cell
            }
            //eventsection -= 1
        //}
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-dd"
        var eventIndexPath = indexPath
        eventIndexPath.section -= 1
        //if currentVenueAttributes.count > 0 {
            eventIndexPath.section -= 1
        //}
        let cell = tableView.dequeueReusableCell(withIdentifier: "venueEventsTableCell", for: indexPath)
        let object = self.fetchedResultController?.object(at: eventIndexPath)
        let rowData = object as! Events
        cell.textLabel?.text = rowData.title! + " [" + rowData.series!.shortTitle! + "]"
        let detailText = coreDataBastard.startDetailLong(event: rowData)
        cell.detailTextLabel?.text = detailText
        return cell
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        //if currentVenueAttributes.count > 0  && indexPath.section == 0 {
        if indexPath.section == 0 {
            return nil
        }
        return indexPath
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        var headerColor : UIColor?
        var eventsection = section
        //if currentVenueAttributes.count > 0 {
            eventsection -= 1
        //}
        //if currentVenueAttributes.count > 0 && section == 0 {
        if section == 0 {
            headerColor = UIColor(red: 0.578125, green: 0.066406, blue: 0.0, alpha: 1.0)
        } else if eventsection == 0 {
            headerColor = UIColor(red: 0.0, green: 0.480469, blue: 0.277344, alpha: 1.0)
        } else {
            headerColor = UIColor(red: 0.0, green: 0.5625, blue: 0.316406, alpha: 1.0)
        }
        /*
            && section == 0 {
            headerColor = UIColor(red: 0.578125, green: 0.066406, blue: 0.0, alpha: 1.0)
            } else {
                eventsection -= 1
            }
        } else if eventsection == 0 {
            headerColor = UIColor(red: 0.0, green: 0.480469, blue: 0.277344, alpha: 1.0)
        } else {
            headerColor = UIColor(red: 0.0, green: 0.5625, blue: 0.316406, alpha: 1.0)
        }
        
        if currentVenueAttributes.count > 0 && section == 0 {
            headerColor = UIColor(red: 0.578125, green: 0.066406, blue: 0.0, alpha: 1.0)
        } else {
            headerColor = UIColor(red: 0.0, green: 0.5625, blue: 0.316406, alpha: 1.0)
        }
         */
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = headerColor
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VenueEventDetailSegue" {
            let destinationViewController = segue.destination as! EventDetailViewController
            var indexPath = self.tableView.indexPathForSelectedRow!
            indexPath.section -= 1
            //if currentVenueAttributes.count > 0 {
                indexPath.section -= 1
            //}
            let object = self.fetchedResultController?.object(at: indexPath)
            let rowData = object as! Events
            //let currentEvent = eventsArray[indexPath.row]
            //destinationViewController.setManagedObjectContext(managedObjectContext: self.managedObjectContext!)
            destinationViewController.setEvent(event: rowData)
            destinationViewController.setExcludedEvents(exclude: [rowData])
        } else if segue.identifier == "VenueMapSegue" {
            let destinationViewController = segue.destination as! VenueMapViewController
            let location = coreDataBastard.venueMapInfo(venue: currentVenue!)
            if location != nil {
                let region = MKCoordinateRegion(center: location!, latitudinalMeters: 2000.0, longitudinalMeters: 2000.0)
                destinationViewController.setMapInfo(center: location, region: region,name: currentVenue?.title)
            }
        }
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
