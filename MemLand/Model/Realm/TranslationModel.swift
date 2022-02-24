//
//  CounterModel.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 6/2/22.
//

import Foundation
import RealmSwift

class TranslationModel: Object {
    @objc dynamic var word: String = ""
    @objc dynamic var sourceName: String = ""
    @objc dynamic var targetName: String = ""
    @objc dynamic var counter: Int = 0
    @objc dynamic var date: NSDate = Date() as NSDate
    var parentProject = LinkingObjects(fromType: ProjectModel.self, property: "translations")
    // the property is how the parent category has called its children
    
//    static func createTranslation(word: String, source: String, target: String) -> TranslationModel {
//        let translation = TranslationModel()
//        translation.word = word
//        translation.sourceName = source
//        translation.targetName = target
//        
//        return translation
//    }
}
