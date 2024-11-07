//
//  ViewController.swift
//  KoKoComboFork
//
//  Created by Chun-Li Cheng on 2024/11/5.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var constructionMsgLabel: UILabel!
    
    
    var genreMessage: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray3
        
        if genreMessage == "" {
            genreLabel.text = "主頁"
        } else {
            genreLabel.text = genreMessage
        }
        genreLabel.textColor = .gray
        genreLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        genreLabel.textAlignment = .center
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        constructionMsgLabel.text = "頁面建構中"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }


}

