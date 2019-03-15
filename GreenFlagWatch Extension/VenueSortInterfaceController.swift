//
//  VenueSortInterfaceController.swift
//  GreenFlagWatch Extension
//
//  Created by B Shield on 2/5/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import WatchKit
import Foundation


class VenueSortInterfaceController: WKInterfaceController {

    private var venueListViewController : VenueListInterfaceController?

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if context != nil {
            venueListViewController = context as? VenueListInterfaceController
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
    @IBAction func sortByAlphaButtonPushed() {
        venueListViewController?.setSortStyle(sortstyle:"alpha")
        self.dismiss()}
    
    @IBAction func sortByContinentButtonPushed() {
        venueListViewController?.setSortStyle(sortstyle:"continent")
        self.dismiss()
    }
}
