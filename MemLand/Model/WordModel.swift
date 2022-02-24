//
//  WordModel.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 17/1/22.
//

import Foundation

protocol DictionaryManagerDelegate {
    func didFindWord(_ dictionaryManager: DictionaryManager, wordModel: WordModel)
    func didFailWithError(message: String)
}

struct WordModel {
    let headWord: String
    let wordClass: String
    
    /* In Nouns: genus
        In Verbs: flexion
        In Adj: ""
        In Prep: ""
     */
    let wordDetail: String
    
    let entries: [WordEntry]
}

struct WordEntry {
    let header: WordHeader
    let translations: [WordTranslation]
}

struct WordHeader {
    let mainHeader: String
    let complementHeader: String
}

struct WordTranslation {
    let source: String
    let target: String
}
