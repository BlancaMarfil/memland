//
//  DictionaryManager.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 12/1/22.
//

import Foundation
import Alamofire
import SwiftSoup

struct DictionaryManager {
    
    let dictionaryURL = "https://api.pons.com/v1/dictionary"
    let headers: HTTPHeaders = ["X-Secret": "013dcb5bb94c5f138c4a063189c12200247c742f606aa62a00bc7018d1d113bc"]
    
    var delegate: DictionaryManagerDelegate?
    
    func fetchData(for word: String, sourceLanguageCode: String, targetLanguageCode: String) {
        
        // sorted language codes, they must be alphabetically ordered independently of source and target
        var codeArray = [sourceLanguageCode, targetLanguageCode]
        codeArray.sort(by: <)
        let lanCodes = codeArray.joined(separator: "")
        
        let parameters = [
            "q": word,
            "l": lanCodes,
            "language": "en"
        ]
        
        AF.request(dictionaryURL,
                   method: .get,
                   parameters: parameters,
                   headers: headers)
            .validate()
            .responseDecodable(of: [WordData].self) { response in
                guard let words = response.value else {
                    print("Word Not Found")
                    self.delegate?.didFailWithError(message: "wordNotFound")
                    return
                }
                
                let parsedWord = parseWord(words)
                
                if let wordFound = parsedWord {
                    self.delegate?.didFindWord(self, wordModel: wordFound)
                }
                else {
                    self.delegate?.didFailWithError(message: "errorDecoding")
                }
                
            }
    }
    
    func parseWord(_ decodedWords: [WordData]) -> WordModel? {

        let information = decodedWords[0].hits[0].roms[0]
        
        let headWord = information.headword
        
        let complementInfo = extractInfoHeadWord(from: information.headword_full)
        let wordClass = complementInfo["wordClass"] ?? ""
        let detail = complementInfo["detail"] ?? ""
        
        var entries: [WordEntry] = []
        
        for arab in information.arabs {
            let headerInfo = extractInfoHeader(from: arab.header)
            let mainHeader = headerInfo["header"] ?? ""
            let complementHeader = headerInfo["complementHeader"] ?? ""
            let header = WordHeader(mainHeader: mainHeader, complementHeader: complementHeader)
            
            var translations: [WordTranslation] = []
            for translation in arab.translations {
                let source = extractHtml(from: translation.source)
                let target = extractHtml(from: translation.target)
                translations.append(WordTranslation(source: source, target: target))
            }
            
            let entry = WordEntry(header: header, translations: translations)
            entries.append(entry)
        }
        
        let word = WordModel(headWord: headWord,
                             wordClass: wordClass,
                             wordDetail: detail,
                             entries: entries)

        return word
    }
    
    func extractHtml(from htmlString: String) -> String {
        
        var output: String = ""
        
        do {
            let doc: Document = try SwiftSoup.parseBodyFragment(htmlString)
            output = try doc.body()!.text()
            
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
        
        return output
    }
    
    func extractInfoHeader(from htmlString: String) -> [String:String] {
        
        var output: [String:String] = [String:String]()
        
        do {
            let doc: Document = try SwiftSoup.parseBodyFragment(htmlString)
            let header = doc.body()?.ownText() ?? ""
            
            let spanList: Elements = try doc.select("span")
            let complementHeader = try Entities.unescape(spanList.first()?.html() ?? "")
            
            output = ["header": header, "complementHeader": complementHeader]
            
            
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
        
        return output
    }
    
    func extractInfoHeadWord(from htmlString: String) -> [String:String] {
        
        var wordClass: String = ""
        let detail: String
        
        var details: [String:String] = [String:String]()
        var output: [String:String] = [String:String]()
        

        do {
            let doc: Document = try SwiftSoup.parseBodyFragment(htmlString)
            let spanList: Elements = try doc.select("span")
            
            for span in spanList {
                
                let spanClass = try span.attr("class")
                let spanHtml = try span.html()
                
                if spanClass == "flexion" {
                    details["flexion"] = try Entities.unescape(spanHtml)
                } else if spanClass == "wordclass" {
                    wordClass = extractAcronym(from: spanHtml) ?? ""
                } else if spanClass == "genus" {
                    details["genus"] = extractAcronym(from: spanHtml) ?? ""
                }
            }
            
            /* If word == verb: details from inflexion
            If word == noun: details from genus */
            switch wordClass {
            case "verb":
                detail = details["flexion"] ?? ""
            case "noun":
                detail = details["genus"] ?? ""
            default:
                detail = ""
            }
            
            output = ["wordClass": wordClass,"detail": detail]
            
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
        
        return output
    }
    
    func extractAcronym(from htmlString: String) -> String? {
        do {
            let spanParsed = try SwiftSoup.parseBodyFragment(htmlString)
            let element = try spanParsed.select("acronym").first()
            if let isElement = element {
                let title = try isElement.attr("title")
                return title
            }
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
        return nil
    }
}
