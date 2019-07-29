//
//  Crossword+CoreDataProperties.swift
//  Crossword
//
//  Created by Brendan Krekeler on 7/28/19.
//  Copyright © 2019 Zukosky, Jonah. All rights reserved.
//
//

import Foundation
import CoreData


extension Crossword {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Crossword> {
        return NSFetchRequest<Crossword>(entityName: "Crossword")
    }

    @NSManaged public var clue: [NSString]?
    @NSManaged public var stringsArray: [NSString]?
    @NSManaged public var title: String?

}
