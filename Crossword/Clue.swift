//
//  Clue.swift
//  Crossword
//
//  Created by Jonah Zukosky on 12/20/18.
//  Copyright © 2018 Zukosky, Jonah. All rights reserved.
//

import Foundation


struct Clue {
    var startingLocation: (Int,Int)?
    var clueNumber: Int
    var orientation: Orientation
    var clue: String?
    var answer: String?
}

enum Orientation {
    case horizontal
    case vertical
}
