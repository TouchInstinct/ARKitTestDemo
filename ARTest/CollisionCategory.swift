//
//  CollisionCategory.swift
//  ARTest
//
//  Created by Grigory Ulanov on 13.06.17.
//  Copyright © 2017 TouchInstinct. All rights reserved.
//

import Foundation

struct CollisionCategory: OptionSet {
    let rawValue: Int

    static let arBullets  = CollisionCategory(rawValue: 1 << 0)
    static let logos = CollisionCategory(rawValue: 1 << 1)
}
