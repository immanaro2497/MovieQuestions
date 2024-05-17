//
//  FreeTextCell.swift
//  MovieQuestions
//
//  Created by Immanuel on 17/05/24.
//

import UIKit

class FreeTextCell: UITableViewCell {

    static let cellIdentifier = "FreeTextCell"
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.gray.cgColor
    }
    
    func configureCell(title: String, text: String) {
        label.text = title
        textView.text = text
    }
    
}
