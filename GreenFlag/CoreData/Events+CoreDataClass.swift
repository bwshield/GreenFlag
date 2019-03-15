//
//  Events+CoreDataClass.swift
//  GreenFlag
//
//  Created by B Shield on 1/24/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Events)
public class Events: NSManagedObject {
    
    @objc var eventMonth : String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let sectionTitle = formatter.string(from:self.endDate! as Date)
        return sectionTitle
    }
    
    @objc var seriesName : String? {
        return self.series?.title
    }
}
