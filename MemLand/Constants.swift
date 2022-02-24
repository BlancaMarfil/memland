//
//  Constants.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 10/1/22.
//
import UIKit

struct K {
    static let appName = "MemLand"
    
    //cells
    static let cellReusableResults = "ResultsCell"
    static let cellReusableLanguages = "LanguagesCell"
    static let cellReusableProjects = "ProjectsCell"
    
    static let cellReusableHistory = "cellReusableHistory"
    static let cellHistoryNibName = "HistoryCell"
    
    static let cellReusableProjectWords = "cellReusableProjectWords"
    
    static let wordCollectionReusableCell = "wordCollectionReusableCell"
    static let projectCollectionReusableCell = "projectCollectionReusableCell"
    
    //segues
    static let chooseLanguageSegue = "chooseLanguageSegue"
    static let listSourceLanguageSegue = "listSourceLanguageSegue"
    static let listTargetLanguageSegue = "listTargetLanguageSegue"
    static let chooseProjectSegue = "chooseProjectSegue"
    static let wordHistorySegue = "wordHistorySegue"
    static let projectWordsSegue = "projectWordsSegue"
    static let wordToProjectSegue = "wordToProjectSegue"
    static let projectWordToHistoryWordSegue = "projectWordToHistoryWordSegue   "
    
    //search text field
    static let searchTextFieldPalceholder = "Search"
    
    //colors
    struct AppColors {
        static let lightBlue = "LightBlue"
        static let lightGreen = "LightGreen"
        static let lightGreenOpacity = "LightGreenOpacity"
    }
    
    //images
    struct AppImages {
        static let searchWord = "search_word"
        static let searchHistory = "search_history"
        static let searchProjects = "search_projects"
    }
    
    struct Defaults {
        static let sourceName = "German"
        static let sourceCode = "de"
        static let sourceImage = "german_flag"
        static let targetName = "English"
        static let targetCode = "en"
        static let targetImage = "english_flag"
        
        static let projectName = "No Project"
        static let flagImageName = "flag.badge.ellipsis"
    }
    
    struct UserDefaultsVariables {
        static let sourceLanguage = "sourceLanguage"
        static let targetLanguage = "targetLanguage"
        static let projectSelected = "projectSelected"
    }
    
    // Navigation Controllers
    struct NavigationControllersTitles {
        static let chooseLanguagesTitle = "Choose Language"
    }
}
