//
//  SelectView.swift
//  MovieQuestions
//
//  Created by Immanuel on 16/05/24.
//

import Foundation
import UIKit

class SelectView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    var didSelect: (() -> Void)?
    
    func configureSelectView(title: String, isSelected: Bool) {
        label.text = title
        imageView.image = isSelected ? UIImage(systemName: "checkmark.circle") : nil
        self.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTap))
        )
    }
    
    @objc func didTap() {
        didSelect?()
    }
    
}
