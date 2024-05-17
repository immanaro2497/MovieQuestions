//
//  SelectCell.swift
//  MovieQuestions
//
//  Created by Immanuel on 16/05/24.
//

import Foundation
import UIKit

class SelectCell: UITableViewCell {
    
    static let cellIdentifier = "SelectCell"
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var optionsStackView: UIStackView!
    
    var selectedChoices: [ChoiceItem] = []
    var isMultiSelect: Bool = false
    var didSelectChoice: ((ChoiceItem) -> Void)?
    
    func configureCell(title: String, isMultiSelect: Bool, choices: [ChoiceItem], selectedChoices: [AnswerChoice]) {
        label.text = title
        self.isMultiSelect = isMultiSelect
        
        optionsStackView.subviews.forEach { $0.removeFromSuperview() }
        
        for choice in choices {
            let selectView: SelectView = Bundle.main.loadNibNamed(String(describing: SelectView.self), owner: nil)?.first as! SelectView
            let isSelected: Bool = {
                for selectedChoice in selectedChoices {
                    if selectedChoice.id == choice.id {
                        return true
                    }
                }
                return false
            }()
            selectView.configureSelectView(title: choice.title, isSelected: isSelected)
            selectView.didSelect = {
                self.didSelectChoice?(choice)
            }
            optionsStackView.addArrangedSubview(selectView)
        }
    }
    
}
