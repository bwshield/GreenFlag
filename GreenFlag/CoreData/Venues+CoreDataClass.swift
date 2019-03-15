//
//  Venues+CoreDataClass.swift
//  GreenFlag
//
//  Created by B Shield on 1/24/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Venues)
public class Venues: NSManagedObject {
    
    @objc var alphasort : String? {
        let firstletter = String((self.shorttitle?.first)!)
        return firstletter
    }

}
