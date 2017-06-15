//
//  ARBullet.swift
//  ARTest
//
//  Created by Grigory Ulanov on 13.06.17.
//  Copyright © 2017 TouchInstinct. All rights reserved.
//

import UIKit
import SceneKit

class ARBullet: SCNNode {

    override init() {
        super.init()

        let arKitBox = SCNSphere(radius: 0.025)
        self.geometry = arKitBox
        let shape = SCNPhysicsShape(geometry: arKitBox, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false

        self.physicsBody?.categoryBitMask = CollisionCategory.arBullets.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.logos.rawValue

        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/ARKit_logo.png")
        self.geometry?.materials  = [material]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
