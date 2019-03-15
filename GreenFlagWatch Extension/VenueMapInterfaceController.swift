//
//  VenueMapInterfaceController.swift
//  GreenFlagWatch Extension
//
//  Created by B Shield on 1/29/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import WatchKit
import Foundation
import MapKit
import CoreData

class VenueMapInterfaceController: WKInterfaceController {

    @IBOutlet weak var mapView: WKInterfaceMap!
    
    private var region : MKCoordinateRegion?
    //private var center : CLLocationCoordinate2D?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        region = context as? MKCoordinateRegion
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if (region != nil) {
            mapView.setRegion(region!)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
