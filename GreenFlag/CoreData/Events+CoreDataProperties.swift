//
//  Events+CoreDataProperties.swift
//  GreenFlag
//
//  Created by B Shield on 1/24/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//
//

import Foundation
import CoreData


extension Events {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Events> {
        return NSFetchRequest<Events>(entityName: "Events")
    }

    @NSManaged public var endDate: NSDate?
    @NSManaged public var eventID: String?
    @NSManaged public var isdeleted: Bool
    @NSManaged public var parentEventID: String?
    @NSManaged public var seriesID: String?
    @NSManaged public var shorttitle: String?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var startTime: NSDate?
    @NSManaged public var tag: String?
    @NSManaged public var timezone: String?
    @NSManaged public var title: String?
    @NSManaged public var venueID: String?
    @NSManaged public var attributes: NSSet?
    @NSManaged public var children: NSSet?
    @NSManaged public var parent: Events?
    @NSManaged public var series: Series?
    @NSManaged public var venue: Venues?

}

// MARK: Generated accessors for attributes
extension Events {

    @objc(addAttributesObject:)
    @NSManaged public func addToAttributes(_ value: EventAttributes)

    @objc(removeAttributesObject:)
    @NSManaged public func removeFromAttributes(_ value: EventAttributes)

    @objc(addAttributes:)
    @NSManaged public func addToAttributes(_ values: NSSet)

    @objc(removeAttributes:)
    @NSManaged public func removeFromAttributes(_ values: NSSet)

}

// MARK: Generated accessors for children
extension Events {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: Events)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: Events)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

