//
//  ProjectModel.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 3/2/22.
//

import Foundation
import RealmSwift

class ProjectModel: Object {
    @objc dynamic var name: String = ""
    var translations = List<TranslationModel>()
    
    func getDifferentTypesOfTranslations() -> [(String,String)] {
        
        typealias languageTuple = (String,String)
        var combinationList: [languageTuple] = []
        
        for t in translations {
            let tmpTuple = languageTuple(t.sourceName,t.targetName)
            if !combinationList.contains(where: {$0 == tmpTuple}) {
                combinationList.append(tmpTuple)
            }
        }
        return combinationList
    }
    
    func getTranslationsFor(source: String, target: String) -> [TranslationModel] {
        
        var translationsFound: [TranslationModel] = []
        for t in translations {
            if t.sourceName == source && t.targetName == target {
                translationsFound.append(t)
            }
        }
        return translationsFound
    }
}
