//
//  LanguageModel.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 29/1/22.
//

import Foundation
import UIKit

struct LanguageModel: Equatable {
    var name: String
    var code: String
    var imageName: String
    
    func getImage() -> UIImage {
        return UIImage(named: imageName) ?? UIImage(systemName: K.Defaults.flagImageName)!
    }
}

struct LanguageModelManager {
    let languageModelList: [LanguageModel] = [
        LanguageModel(name: "Chinese", code: "zh", imageName: "chinese_flag"),
        LanguageModel(name: "Czech", code: "cs", imageName: "czech_flag"),
        LanguageModel(name: "Dutch", code: "nl", imageName: "dutch_flag"),
        LanguageModel(name: "English", code: "en", imageName: "english_flag"),
        LanguageModel(name: "Finnish", code: "fi", imageName: "finnish_flag"),
        LanguageModel(name: "French", code: "fr", imageName: "french_flag"),
        LanguageModel(name: "German", code: "de", imageName: "german_flag"),
        LanguageModel(name: "Greek", code: "el", imageName: "greek_flag"),
        LanguageModel(name: "Italian", code: "it", imageName: "italian_flag"),
        LanguageModel(name: "Portuguese", code: "pt", imageName: "portuguese_flag"),
        LanguageModel(name: "Spanish", code: "es", imageName: "spanish_flag"),
        LanguageModel(name: "Swedish", code: "sv", imageName: "swedish_flag"),
    ]
    
    func getLanguageModel(byName name: String) -> LanguageModel? {
        for lanModel in languageModelList{
            if lanModel.name == name {
                return lanModel
            }
        }
        return nil
    }
    
    func getDefaultSourceLanguage() -> LanguageModel {
        return LanguageModel(name: K.Defaults.sourceName, code: K.Defaults.sourceCode, imageName: K.Defaults.sourceImage)
    }
    
    func getDefaultTargetLanguage() -> LanguageModel {
        return LanguageModel(name: K.Defaults.targetName, code: K.Defaults.targetCode, imageName: K.Defaults.targetImage)
    }
}

/*
 New Beginnings:
 Empörung
 anstoßen
 Sieg
 bemühen
 behutsam
 
 Berühre Mich. Nicht
 irritieren
 Wahnsinn
 redselig
 Bedauern
 
 Like Snow We Fall
 Spitze
 Abgrund
 begabte
 insgeheim
 
 
 */

