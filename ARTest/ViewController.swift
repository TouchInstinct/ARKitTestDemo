//
//  ViewController.swift
//  ARTest
//
//  Created by Grigory Ulanov on 08.06.17.
//  Copyright © 2017 TouchInstinct. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

private enum GameState {
    case placing
    case shootting
}

class ViewController: UIViewController, ARSCNViewDelegate {

    private static let logoMaxCount = 3

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var prizelImageView: UIImageView!
    
    fileprivate var state: GameState = .placing {
        didSet {
            prizelImageView.isHidden = state == .placing
        }
    }
    fileprivate var logoCount = 0 {
        didSet {
            DispatchQueue.main.async {
                self.scoreLabel.text = "\(self.logoCount)"
            }
        }
    }
    fileprivate var gameSeconds = 0

    fileprivate var gameTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.scene.physicsWorld.contactDelegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        sceneView.addGestureRecognizer(tapGestureRecognizer)

        logoCount = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARSessionConfiguration.isSupported ? ARWorldTrackingSessionConfiguration()
                                                               : ARSessionConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        stopGame()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    @objc private func tapAction() {
        switch state {
        case .placing:
            addLogo()
        case .shootting:
            shoot()
        }
    }

    private func addLogo() {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }

        let logo = Logo()
        sceneView.scene.rootNode.addChildNode(logo)

        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1
        logo.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)

        logoCount += 1
        if logoCount == ViewController.logoMaxCount {
            startGame()
        }
    }

    private func shoot() {
        let arBullet = ARBullet()

        let (direction, position) = cameraVector
        arBullet.position = position

        let bulletDirection = direction
        arBullet.physicsBody?.applyForce(bulletDirection, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(arBullet)
    }

}

extension ViewController {

    fileprivate func startGame() {
        state = .shootting

        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.gameSeconds += 1
            DispatchQueue.main.async {
                self?.configureTimeLabel()
            }
        })
    }

    fileprivate func stopGame() {
        state = .placing

        gameTimer?.invalidate()
        gameTimer = nil

        gameSeconds = 0
        logoCount = 0

        configureTimeLabel()
    }

    fileprivate func configureTimeLabel() {
        self.timeLabel.isHidden = self.gameSeconds == 0

        let seconds = self.gameSeconds % 60
        let minutes = (self.gameSeconds / 60) % 60;

        self.timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

}

extension ViewController {

    fileprivate var cameraVector: (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4FromMat4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space

            return (dir, pos)
        }
        return (SCNVector3(0, 0, 0), SCNVector3(0, 0, 0))
    }

}

extension ViewController: SCNPhysicsContactDelegate {

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard let nodeABitMask = contact.nodeA.physicsBody?.categoryBitMask,
            let nodeBBitMask = contact.nodeB.physicsBody?.categoryBitMask,
            nodeABitMask & nodeBBitMask == CollisionCategory.logos.rawValue & CollisionCategory.arBullets.rawValue else {
                return
        }

        contact.nodeB.removeFromParentNode()
        logoCount -= 1

        if logoCount == 0 {
            DispatchQueue.main.async {
                self.stopGame()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            contact.nodeA.removeFromParentNode()
        })
    }

}
