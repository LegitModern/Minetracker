//
//  CollectionTypeExtension.swift
//  Minetracker
//
//  Created by Ryan Donaldson on 7/20/16.
//  Copyright © 2016 Ryan Donaldson. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
