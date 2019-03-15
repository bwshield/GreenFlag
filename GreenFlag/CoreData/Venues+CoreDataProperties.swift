//
//  Venues+CoreDataProperties.swift
//  GreenFlag
//
//  Created by B Shield on 1/24/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//
//

import Foundation
import CoreData


extension Venues {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Venues> {
        return NSFetchRequest<Venues>(entityName: "Venues")
    }

    @NSManaged public var isdeleted: Bool
    @NSManaged public var shorttitle: String?
    @NSManaged public var tag: String?
    @NSManaged public var timezone: String?
    @NSManaged public var title: String?
    @NSManaged public var venueID: String?
    @NSManaged public var continent: String?
    //@NSManaged public var alphasort: String?
    @NSManaged public var attributes: NSSet?
    @NSManaged public var events: NSSet?

}

// MARK: Generated accessors for attributes
extension Venues {

    @objc(addAttributesObject:)
    @NSManaged public func addToAttributes(_ value: VenueAttributes)

    @objc(removeAttributesObject:)
    @NSManaged public func removeFromAttributes(_ value: VenueAttributes)

    @objc(addAttributes:)
    @NSManaged public func addToAttributes(_ values: NSSet)

    @objc(removeAttributes:)
    @NSManaged public func removeFromAttributes(_ values: NSSet)

}

// MARK: Generated accessors for events
extension Venues {

    @objc(addEventsObject:)
    @NSManaged public func addToEvents(_ value: Events)

    @objc(removeEventsObject:)
    @NSManaged public func removeFromEvents(_ value: Events)

    @objc(addEvents:)
    @NSManaged public func addToEvents(_ values: NSSet)

    @objc(removeEvents:)
    @NSManaged public func removeFromEvents(_ values: NSSet)

}
