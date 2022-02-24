//
//  ModelManager.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 6/2/22.
//

import Foundation
import RealmSwift

class ModelManager {
    
    let realm = try! Realm()
    var projects: Results<ProjectModel>?
    var translations: Results<TranslationModel>?
    
    init() {
        projects = loadProjects()
        translations = loadTranslations()
    }
    
    //MARK: - Projects
    
    func loadProjects() -> Results<ProjectModel> {
        return realm.objects(ProjectModel.self).sorted(byKeyPath: "name")
    }
    
    func getProjects() -> [ProjectModel]? {
        projects = loadProjects()
        guard let projectList = projects else { return nil }
        return Array(projectList)
    }
    
    func getAbsoluteProjects() -> [ProjectModel] {
        // Returns all prjects except the "No Project" one
        var finalList: [ProjectModel] = []
        if let allProjects = getProjects() {
            for p in allProjects {
                if p.name != K.Defaults.projectName {
                    finalList.append(p)
                }
            }
        }
        return finalList
    }
    
    func findProject(byName name: String) -> ProjectModel? {
        return projects?.filter("name == %@", name).first
    }
    
    func saveProject(_ project: ProjectModel) {
        do {
            try realm.write {
                if findProject(byName: project.name) == nil {
                    realm.add(project)
                }
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func updateProjectName(project: ProjectModel, newName: String) -> ProjectModel {
        do {
            try realm.write {
                project.name = newName
            }
        } catch {
            print("Error saving context, \(error)")
        }
        return project
    }
    
    func deleteProject(_ project: ProjectModel) {
        do {
            try realm.write {
                guard let projectFound = findProject(byName: project.name) else { return }
                realm.delete(projectFound)
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    func deleteAllProjects() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Error deleting context, \(error)")
        }
    }
    
    
    //MARK: - Words
    
    func loadTranslations() -> Results<TranslationModel> {
        return realm.objects(TranslationModel.self).sorted(byKeyPath: "date", ascending: false)
    }
    
    func getTranslations() -> [TranslationModel]? {
        translations = loadTranslations()
        guard let translationsList = translations else { return nil }
        let array = Array(translationsList).sorted(by: { $0.date as Date > $1.date as Date })
        return array
    }
    
    func findTranslations(byWord word: String) -> [TranslationModel] {
        let translationsSearched = translations?.filter("word == %@", word)
        guard let translationsFound = translationsSearched else { return [] }
        return Array(translationsFound)
    }
    
    func addWord(word: String, source: String, target: String, toProject project: String) -> TranslationModel {
        
        var wordAdded = TranslationModel()
        var wordSearched: TranslationModel?
        
        var projectFound: ProjectModel?
        
        
        if let ps = projects {
            projectFound = ps.filter("name == %@", project).first
            
            if let p = projectFound {
                // Update counter and date
                wordSearched = p.translations.filter(
                    "word == %@ AND sourceName == %@ AND targetName == %@",
                    word, source, target).first
                
                if let wordFound = wordSearched {
                    do {
                        try realm.write {
                            wordFound.counter += 1
                            wordFound.date = Date() as NSDate
                            
                            wordAdded = wordFound
                        }
                    } catch {
                        print("Error saving context, \(error)")
                    }
                } else {
                    do {
                        try realm.write {
                            wordAdded.word = word.lowercased()
                            wordAdded.sourceName = source
                            wordAdded.targetName = target
                            wordAdded.counter += 1
                            wordAdded.date = Date() as NSDate
                            p.translations.append(wordAdded)
                        }
                    } catch {
                        print("Error saving context, \(error)")
                    }
                }
            }
        }
        return wordAdded
    }
    
    func getProjectAndCounterFromTranslation(_ translation: TranslationModel) -> [String:Int] {
        
        var projectCounter: [String:Int] = [:]
        
        if let projectList = projects {
            for p in projectList{
                for t in p.translations {
                    if t.word == translation.word {
                        projectCounter[p.name] = t.counter
                    }
                }
            }
        }
        
        return projectCounter
    }
    
    func deleteTranslationsFromAllProjects(_ translation: TranslationModel) {
        let translationsFound = findTranslations(byWord: translation.word)
        do {
            try realm.write {
                for translation in translationsFound {
                    realm.delete(translation)
                }
            }
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
//    func getAllTimesSearched(forTranslation translation: TranslationModel) -> Int {
//
//        var totalCounter = 0
//
//        if let translationsList = translations {
//            for t in translationsList {
//                if t.word == translation.word {
//                    totalCounter += t.counter
//                }
//            }
//        }
//
//        return totalCounter
//    }
    
    //MARK: - History
    
    func deleteAllTranslations() {
        do {
            try realm.write {
                guard let translationsList = translations else { return }
                realm.delete(translationsList)
            }
        } catch {
            print("Error deleting context, \(error)")
        }
    }
    
}
