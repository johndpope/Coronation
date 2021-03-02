//
//  InformationViewController.swift
//  Coronation
//
//  Created by Ulrika Alm on 2021-02-24.
//

import UIKit

class InformationViewController: UIViewController {
    
    var selectedCrown: VirtualContentType?
    
    @IBOutlet var titleLabel: UILabel?
    
    private func updateView() {
        titleLabel?.text = selectedCrown?.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        

        // Do any additional setup after loading the view.
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
