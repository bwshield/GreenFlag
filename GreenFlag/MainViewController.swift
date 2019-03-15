//
//  MainViewController.swift
//  GreenFlag
//
//  Created by B Shield on 1/27/19.
//  Copyright © 2019 Brian Shield. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    
    private let coreDataBastard = CoreDataBastard.sharedBastard
    
    @IBOutlet weak var activitityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //topImageView.image = UIImage(named: "icon180.png")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if coreDataBastard.checkForUpdateFile() {
            coreDataBastard.parseUpdateFile()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
