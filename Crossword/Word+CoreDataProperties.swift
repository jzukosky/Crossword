//
//  Word+CoreDataProperties.swift
//  Crossword
//
//  Created by Brendan Krekeler on 5/14/19.
//  Copyright © 2019 Zukosky, Jonah. All rights reserved.
//
//

import Foundation
import CoreData


extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var row: Int64
    @NSManaged public var col: Int64
    @NSManaged public var direction: String?
    @NSManaged public var word: String?
    @NSManaged public var clue: String?

}
