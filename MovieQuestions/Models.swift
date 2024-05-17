//
//  Models.swift
//  MovieQuestions
//
//  Created by Immanuel on 17/05/24.
//

import Foundation

// MARK: From API
struct Choice: Codable {
    let id: Int
    let title: String
    let nasClass: String
    let question: Int
    let questions: [ResultQuestion]?

    enum CodingKeys: String, CodingKey {
        case id, title
        case nasClass = "nas_class"
        case question, questions
    }
}

struct ResultQuestion: Codable {
    let id: Int
    let title, description, type: String
    let assessment: Int
    let choices: [Choice]?
    let choice: Int?
    let creator: Int
}

struct Response: Codable {
    let results: [ResultQuestion]
}


// MARK: For originalQuestions. One question with choices
struct TreeItem {
    let id: Int
    let title, description, type: String
    let assessment: Int
    let choices: [ChoiceItem]
    let choice: Int?
    let creator: Int
}


struct ChoiceItem {
    let id: Int
    let title: String
    let nasClass: String
    let question: Int
}


// MARK: For questionsWithAnswer. One question with user selected choices
class QuestionWithAnswer {
    let id: Int
    let choice: Int?
    var choices: [AnswerChoice]
    var freeText: String
    
    init(id: Int, choice: Int?, choices: [AnswerChoice], freeText: String) {
        self.id = id
        self.choice = choice
        self.choices = choices
        self.freeText = freeText
    }
}

class AnswerChoice {
    let id: Int
    let question: Int
    
    init(id: Int, question: Int) {
        self.id = id
        self.question = question
    }
}
