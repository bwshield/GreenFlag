//
//  EventSortInterfaceController.swift
//  GreenFlag
//
//  Created by B Shield on 2/5/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import WatchKit
import Foundation


class EventSortInterfaceController: WKInterfaceController {
    
    private var eventListViewController : EventListInterfaceController?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if context != nil {
            eventListViewController = context as? EventListInterfaceController
        }
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    @IBAction func sortByDateButtonPushed() {
        eventListViewController?.setSortStyle(sortstyle:"date")
        self.dismiss()
    }
    @IBAction func sortBySeriesButtonPushed() {
        eventListViewController?.setSortStyle(sortstyle:"series")
        self.dismiss()
    }
    @IBAction func sortByContinentButtonPushed() {
        eventListViewController?.setSortStyle(sortstyle:"continent")
        self.dismiss()
    }
}
