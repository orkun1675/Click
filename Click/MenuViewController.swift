//
//  MenuViewController.swift
//  Click
//
//  Created by Orkun Duman on 25/03/15.
//  Copyright (c) 2015 OBD. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var start: UIImageView!
    var iconAnimating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        icon.image = UIImage(named: "img/click180.png")
        start.image = UIImage(named: "img/start_icon.png")
        start.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MenuViewController.tapped(_:))))
        icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MenuViewController.iconTouch(_:))))
        
        AudioManager.startClickMain()
    }
    
    func rotateFirstHalf() {
        iconAnimating = true
        UIView.animate(withDuration: 1.5, animations: {
            self.icon.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI) * 1.0)
            }, completion:
            {_ in
                self.rotateSecondHalf()
            }
        )
    }
    
    func rotateSecondHalf() {
        UIView.animate(withDuration: 1.5, animations: {
            self.icon.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI) * 0.0)
            }, completion:
            {_ in
                self.iconAnimating = false
            }
        )
    }
    
    @IBAction func startGame(_ sender: AnyObject) { //Start Game button click
        startGameModal()
    }
    
    func tapped(_ gesture: UITapGestureRecognizer) { //Start icon click
        startGameModal()
    }
    
    func startGameModal() {
        AudioManager.stopClickMain()
        performSegue(withIdentifier: "mainToGame", sender: self)
    }
    
    func iconTouch(_ gesture: UITapGestureRecognizer) {
        if !iconAnimating {
            rotateFirstHalf()
        }
    }
    
}
