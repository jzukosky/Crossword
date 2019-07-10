//
//  Crossword+CoreDataClass.swift
//  Crossword
//
//  Created by Brendan Krekeler on 5/15/19.
//  Copyright © 2019 Zukosky, Jonah. All rights reserved.
//
//

import UIKit
import CoreData


public class Crossword: NSManagedObject {
    
    
    convenience init?(title: String, clue: ValueTransformer, stringsArray: ValueTransformer) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext
            else {
                return nil
        }
        self.init(entity: Crossword.entity(), insertInto: managedContext)
        self.title = title
        self.stringsArray = stringsArray
        self.clue = clue
    }
    
    //func update(title: String, stringsArray: ValueTransformer, clue: ValueTransformer){
    //
    //}
}
