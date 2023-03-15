//
//  History.swift
//  OpenAI
//
//  Created by Nikita Pishchugin on 15.03.23.
//

import UIKit
import RealmSwift

class History: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var userQuestion: String? = ""
    @Persisted var openAIResponse: String? = ""
    
    convenience init(userQuestion: String?,
                     openAIResponse: String?) {
        self.init()
        self.userQuestion = userQuestion
        self.openAIResponse = openAIResponse
    }
}
