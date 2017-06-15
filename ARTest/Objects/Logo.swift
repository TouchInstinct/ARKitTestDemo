//
//  Logo.swift
//  ARTest
//
//  Created by Grigory Ulanov on 13.06.17.
//  Copyright © 2017 TouchInstinct. All rights reserved.
//

import UIKit
import SceneKit

class Logo: SCNNode {

    override init() {
        super.init()

        let logo = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        self.geometry = logo
        let shape = SCNPhysicsShape(geometry: logo, options: nil)

        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false

        self.physicsBody?.categoryBitMask = CollisionCategory.logos.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.arBullets.rawValue

        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/logo-mobile.png")
        self.geometry?.materials  = [material, material, material, material, material, material]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
