//
//  ViewController.swift
//  MovieQuestions
//
//  Created by Immanuel on 16/05/24.
//

import UIKit
import Combine

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var originalQuestions: [TreeItem] = []
    var questionsWithAnswer: [QuestionWithAnswer] = []
    var currentQuestionWithAnswerIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getOriginalQuestionsFromJSON()
        getMandatoryQuestions()
        configureTableView()
        configureButtons()
    }
    
    func getOriginalQuestionsFromJSON() {
        if let fileURL = Bundle.main.url(forResource: "QuestionJSON", withExtension: "json"),
           let data = try? Data(contentsOf: fileURL),
           let response = try? JSONDecoder().decode(Response.self, from: data) {
            let resultsQuestions = response.results
            let trees = convertTreeToArray(resultsQuestions)
            originalQuestions = trees
        }
    }
    
    func convertTreeToArray(_ roots: [ResultQuestion]?) -> [TreeItem] {
        guard let roots = roots else {
            return []
        }
        
        var result: [TreeItem] = []
        
        for root in roots {
            result.append(contentsOf: convertNodeToArray(root))
        }
        
        return result
    }
    
    func convertNodeToArray(_ node: ResultQuestion) -> [TreeItem] {
        var result: [TreeItem] = [TreeItem(id: node.id,
                                           title: node.title,
                                           description: node.description,
                                           type: node.type,
                                           assessment: node.assessment,
                                           choices: convertChoices(node.choices),
                                           choice: node.choice,
                                           creator: node.creator)]
        
        if let choices = node.choices {
            for choice in choices {
                // Choice questions will be added as new TreeItem. So ChoiceItem will not have questions property, for avoiding extra data or duplicating.
                if let questions = choice.questions {
                    result += questions.flatMap { convertNodeToArray($0) }
                }
            }
        }
        
        return result
    }
    
    func convertChoices(_ choices: [Choice]?) -> [ChoiceItem] {
        guard let choices = choices else {
            return []
        }
        return choices.map { choice in
            return ChoiceItem(
                id: choice.id,
                title: choice.title,
                nasClass: choice.nasClass,
                question: choice.question
            )
        }
    }
    
    func getMandatoryQuestions() {
        for question in originalQuestions {
            // If choice is nil, the question should be shown by default
            if question.choice == nil {
                questionsWithAnswer.append(
                    QuestionWithAnswer(
                        id: question.id,
                        choice: question.choice,
                        choices: [],
                        freeText: ""
                    )
                )
            }
        }
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.register(UINib(nibName: SelectCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: SelectCell.cellIdentifier)
        tableView.register(UINib(nibName: FreeTextCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: FreeTextCell.cellIdentifier)
    }
    
    func configureButtons() {
        previousButton.isEnabled = currentQuestionWithAnswerIndex != 0
        nextButton.isEnabled = currentQuestionWithAnswerIndex < (questionsWithAnswer.count - 1)
    }
    
    // MARK: tableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsWithAnswer.isEmpty ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentQuestionWithAnswer = questionsWithAnswer[currentQuestionWithAnswerIndex]
        // using currentOriginalQuestion to populate title, choices name and other work
        let currentOriginalQuestion = originalQuestions.first(where: { $0.id == currentQuestionWithAnswer.id })!
        
        let title = "Q \(currentQuestionWithAnswerIndex + 1)) \(currentOriginalQuestion.title)"
        
        if currentOriginalQuestion.type == "multi_select" || currentOriginalQuestion.type == "single_select" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectCell.cellIdentifier, for: indexPath) as! SelectCell
            
            cell.configureCell(
                title: title,
                isMultiSelect: currentOriginalQuestion.type == "multi_select",
                choices: currentOriginalQuestion.choices,
                selectedChoices: currentQuestionWithAnswer.choices
            )
            
            cell.didSelectChoice = {[weak self] choiceItem in
                
                guard let weakSelf = self else {
                    return
                }
                
                if currentOriginalQuestion.type == "single_select" {
                    weakSelf.didSelectSingleChoice(choiceItem: choiceItem, currentQuestionWithAnswer: currentQuestionWithAnswer)
                } else {
                    weakSelf.didSelectMultiChoice(choiceItem: choiceItem, currentQuestionWithAnswer: currentQuestionWithAnswer)
                }
                weakSelf.reloadTableAndButtons()
                
            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: FreeTextCell.cellIdentifier, for: indexPath) as! FreeTextCell
            cell.configureCell(title: title, text: "")
            return cell
            
        }
        
    }
    
    func didSelectSingleChoice(choiceItem: ChoiceItem, currentQuestionWithAnswer: QuestionWithAnswer) {
        
        let previousChoiceId = currentQuestionWithAnswer.choices.first?.id
        
        if previousChoiceId == choiceItem.id {
            
            currentQuestionWithAnswer.choices = []
            // removing the questions related to choice
            filterQuestionsWithAnswerOnChoiceSelect(choiceId: choiceItem.id)
            
        } else {
            
            if let previousChoiceId {
                // removing the questions related to previousChoiceId, because this is single select
                filterQuestionsWithAnswerOnChoiceSelect(choiceId: previousChoiceId)
            }
            
            currentQuestionWithAnswer.choices = [AnswerChoice(id: choiceItem.id, question: choiceItem.question)]
            // creating new QuestionWithAnswer for choice
            createQuestionsWithAnswerForChoice(choiceId: choiceItem.id)
            
        }
        
    }
    
    func didSelectMultiChoice(choiceItem: ChoiceItem, currentQuestionWithAnswer: QuestionWithAnswer) {
        
        if let index = currentQuestionWithAnswer.choices.firstIndex(where: { $0.id == choiceItem.id }) {
            
            var choices = currentQuestionWithAnswer.choices
            choices.remove(at: index)
            currentQuestionWithAnswer.choices = choices
            // removing the questions related to choice
            filterQuestionsWithAnswerOnChoiceSelect(choiceId: choiceItem.id)
            
        } else {
            
            var choices = currentQuestionWithAnswer.choices
            choices.append(AnswerChoice(id: choiceItem.id, question: choiceItem.question))
            currentQuestionWithAnswer.choices = choices
            // creating new QuestionWithAnswer for choice
            createQuestionsWithAnswerForChoice(choiceId: choiceItem.id)
            
        }
        
    }
    
    // if choice has questions, it will be inserted
    func createQuestionsWithAnswerForChoice(choiceId: Int) {
        
        let questions =  originalQuestions.compactMap({
            if $0.choice == choiceId {
                return QuestionWithAnswer(id: $0.id, choice: $0.choice, choices: [], freeText: "")
            }
            return nil
        })
        
        if currentQuestionWithAnswerIndex + 1 < questionsWithAnswer.count {
            questionsWithAnswer.insert(contentsOf: questions, at: currentQuestionWithAnswerIndex + 1)
        } else {
            questionsWithAnswer.append(contentsOf: questions)
        }
        
    }
    
    // removing the questions which belong to choiceIds
    func filterQuestionsWithAnswerOnChoiceSelect(choiceId: Int) {
        
        var questionsToBeRemovedWithChoiceId: Set<Int> = [choiceId]
        
        var filteredQuestionsWithAnswer: [QuestionWithAnswer] = []
        
        for question in questionsWithAnswer {
            if let questionChoiceId = question.choice, questionsToBeRemovedWithChoiceId.contains(questionChoiceId) {
                
                for choice in question.choices {
                    questionsToBeRemovedWithChoiceId.insert(choice.id)
                }
                
            } else {
                filteredQuestionsWithAnswer.append(question)
            }
        }
        
        questionsWithAnswer = filteredQuestionsWithAnswer
        
    }
    
    // MARK: Next and Previous button actions
    @IBAction func tappedPreviousButton(_ sender: UIButton) {
        changeQuestion(toNext: false)
    }
    
    @IBAction func tappedNextButton(_ sender: UIButton) {
        changeQuestion(toNext: true)
    }
    
    func changeQuestion(toNext: Bool) {
        if toNext {
            currentQuestionWithAnswerIndex += 1
        } else {
            currentQuestionWithAnswerIndex -= 1
        }
        reloadTableAndButtons()
    }
    
    func reloadTableAndButtons() {
        configureButtons()
        tableView.reloadData()
    }


}

