//
//  ViewController.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 5/1/22.
//

import UIKit

class SearchViewController: UIViewController {
    
    // User Defaults
    let userDefaults = UserDefaults.standard

    // Project
    @IBOutlet weak var selectProjectButton: UIButton!
    
    // Choose Languages
    @IBOutlet weak var sourceLanguageButton: UIButton!
    @IBOutlet weak var targetLanguageButton: UIButton!
    @IBOutlet weak var exchangeLanguageButton: UIButton!
    
    // Search Bar
    @IBOutlet weak var searchWordTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var timesSearchedView: UIView!
    @IBOutlet weak var timesSearchedLabel: UILabel!
    
    // Word Found
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var wordClassLabel: UILabel!
    @IBOutlet weak var wordDetailLabel: UILabel!
    
    // Table View
    @IBOutlet weak var tableView: UITableView!
    
    // Images
    @IBOutlet weak var noSearchImage: UIImageView!
    @IBOutlet weak var notFoundErrorImage: UIImageView!
    
    // Languages
    private let languageManager = LanguageModelManager()
    private var sourceLanguageModel: LanguageModel?
    private var targetLanguageModel: LanguageModel?
    
    // Project & Translation
    private var projectSelected: ProjectModel?
    private var timesSearched: Int = 0
    private var translationSearched: TranslationModel? {
        didSet {
            timesSearched = translationSearched?.counter ?? 0
        }
    }
    
    private var isError: Bool = false
    
    // Realm Manager
    let modelManager = ModelManager()
    
    // Dictionary
    private var wordModel: WordModel?
    private var dictionaryManager = DictionaryManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // standard delegates
        tableView.dataSource = self
        tableView.delegate = self
        searchWordTextField.delegate = self
        
        // model delegates
        dictionaryManager.delegate = self

        // initializers
        isError = false
        setWordValues()
        setLanguageModels()
        setProject()
        setUIInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isError = false
        setWordValues()
        setProject()
        setUIInfo()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: - Change Project Button functions
    
    @IBAction func changeProjectPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: K.chooseProjectSegue, sender: self)
    }
    
    //MARK: - Change Language Buttons functions

    @IBAction func exchangeLanguagePressed(_ sender: UIButton) {
        let tempLanguageModel = sourceLanguageModel
        sourceLanguageModel = targetLanguageModel
        targetLanguageModel = tempLanguageModel
        setUIInfo()
    }
    
    
    @IBAction func changeLanguagePressed(_ sender: Any) {
        self.performSegue(withIdentifier: K.chooseLanguageSegue, sender: self)
    }
    
    //MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == K.chooseLanguageSegue {
            
            let destinationVC = segue.destination as! ChooseLanguageViewController
            destinationVC.delegate = self
            
            destinationVC.sourceLanguage = sourceLanguageModel
            destinationVC.targetLanguage = targetLanguageModel
            
        } else if segue.identifier == K.chooseProjectSegue {
            
            let destinationVC = segue.destination as! ChooseProjectViewController
            destinationVC.delegate = self
            
            destinationVC.projectSelected = projectSelected
        }
    }
}

//MARK: - Initializers

extension SearchViewController {
    
    func setWordValues(forWord wordValue: WordModel? = nil) {
        
        self.wordModel = wordValue
        
        if let wordFound = wordModel {
            wordLabel.text = wordFound.headWord
            wordClassLabel.text = wordFound.wordClass
            wordDetailLabel.text = wordFound.wordDetail
            self.noSearchImage.isHidden = true
            tableView.reloadData()
        } else {
            wordLabel.text = ""
            wordClassLabel.text = ""
            wordDetailLabel.text = ""
            searchWordTextField.text = ""
            timesSearchedView.isHidden = true
            self.noSearchImage.isHidden = false
            timesSearched = 0
            tableView.reloadData()
        }
    }
    
    func setLanguageModels() {
        if let sourceLan = userDefaults.object(forKey: K.UserDefaultsVariables.sourceLanguage) as? String,
           let targetLan = userDefaults.object(forKey: K.UserDefaultsVariables.targetLanguage) as? String {
            sourceLanguageModel = languageManager.getLanguageModel(byName: sourceLan)
            targetLanguageModel = languageManager.getLanguageModel(byName: targetLan)
        } else {
            sourceLanguageModel = languageManager.getDefaultSourceLanguage()
            targetLanguageModel = languageManager.getDefaultTargetLanguage()
        }
    }
    
    func setProject() {
        if let project = userDefaults.object(forKey: K.UserDefaultsVariables.projectSelected) as? String {
            let projectSearched = modelManager.findProject(byName: project)
            if let projectFound = projectSearched {
                projectSelected = projectFound
            } else {
                projectSelected = nil
            }
        } else {
            let newProject = ProjectModel()
            newProject.name = K.Defaults.projectName
            modelManager.saveProject(newProject)
            projectSelected = newProject
        }
    }
    
    func setUIInfo() {
        // Source and Traget languages
        if let sourceLan = sourceLanguageModel,
           let targetLan = targetLanguageModel {
            sourceLanguageButton.setTitle(sourceLan.name, for: .normal)
            targetLanguageButton.setTitle(targetLan.name, for: .normal)
            
            sourceLanguageButton.setImage(sourceLan.getImage(), for: .normal)
            targetLanguageButton.setImage(targetLan.getImage(), for: .normal)
        }
        
        // Project
        if let project = projectSelected {
            selectProjectButton.setTitle(project.name, for: .normal)
        } else {
            selectProjectButton.setTitle(K.Defaults.projectName, for: .normal)
        }
        
        // Times searched
        if timesSearched > 0  && !isError {
            timesSearchedView.isHidden = false
            timesSearchedView.layer.cornerRadius = 5
            timesSearchedLabel.text = "\(timesSearched)"
        } else {
            timesSearchedView.isHidden = true
        }
        
        notFoundErrorImage.isHidden = !self.isError
    }
}

//MARK: - ChooseDelegates

extension SearchViewController: ChooseLanguageDelegate, ChooseProjectDelegate {
    
    //MARK: - Choose Language Delegate
    
    func setChosenLanguages(source: LanguageModel, target: LanguageModel) {
        sourceLanguageModel = source
        targetLanguageModel = target
        
        timesSearched = 0
        setUIInfo()
        setWordValues()
        tableView.reloadData()
        searchWordTextField.text = ""
        
        // setting user defaults
        userDefaults.set(source.name, forKey: K.UserDefaultsVariables.sourceLanguage)
        userDefaults.set(target.name, forKey: K.UserDefaultsVariables.targetLanguage)
    }
    
    //MARK: - Choose Project Delegate
    
    func setChosenProject(_ project: ProjectModel) {
        projectSelected = project
        userDefaults.set(project.name, forKey: K.UserDefaultsVariables.projectSelected)
        
        timesSearched = 0
        setUIInfo()
        setWordValues()
        tableView.reloadData()
        searchWordTextField.text = ""
    }
    
}

//MARK: - Dictionary Manager Delegate

extension SearchViewController: DictionaryManagerDelegate {
    
    func didFindWord(_ dictionaryManager: DictionaryManager, wordModel: WordModel) {
        DispatchQueue.main.async {
            
            if let sourceModel = self.sourceLanguageModel,
               let targetModel = self.targetLanguageModel,
               let project = self.projectSelected {
                self.translationSearched = self.modelManager.addWord(word: wordModel.headWord.lowercased(),
                                                                     source: sourceModel.name,
                                                                     target: targetModel.name,
                                                                     toProject: project.name)
            }
            self.isError = false
            self.setWordValues(forWord: wordModel)
            self.setUIInfo()
        }
    }
    
    func didFailWithError(message: String) {
        
        DispatchQueue.main.async {
            self.isError = true
            
            switch message {
            case "wordNotFound":
                print("Word not found")
            case "errorDecoding":
                print("Error decoding")
            default:
                print("Generic error")
            }
            
            self.setWordValues(forWord: nil)
            self.setUIInfo()
            self.tableView.reloadData()
        }
    }
}

//MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchWordTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchWordTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if searchWordTextField.text != "" {
            return true
        } else {
            searchWordTextField.placeholder = K.searchTextFieldPalceholder
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let sourceModel = sourceLanguageModel, let targetModel = targetLanguageModel {
            if let word = searchWordTextField.text {
                dictionaryManager.fetchData(
                    for: word,
                       sourceLanguageCode: sourceModel.code,
                       targetLanguageCode: targetModel.code)
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        setWordValues()
        tableView.reloadData()
        return true
    }
}

//MARK: - UITableViewDelegates

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let word = wordModel {
            return word.entries.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let word = wordModel {
            return word.entries[section].translations.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 || self.tableView(tableView, viewForHeaderInSection: section) == nil {
            return 0
        } else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let word = wordModel else { return nil }
        let header = word.entries[section].header
        
        if header.mainHeader == "" {
            return nil
        } else {
        
            let sectionHeaderView = UIView()
            sectionHeaderView.backgroundColor = .systemGray6
            sectionHeaderView.layer.cornerRadius = 5
            
            let label = UILabel()

            let firstAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            let secondAttributes = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 14)]

            let firstString = NSMutableAttributedString(string: "\(header.mainHeader) ", attributes: firstAttributes)
            let secondString = NSAttributedString(string: header.complementHeader, attributes: secondAttributes)

            firstString.append(secondString)
            
            label.attributedText = firstString
            label.frame = CGRect(x: 5, y: 0, width: view.frame.width, height: 30)
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            
            sectionHeaderView.addSubview(label)
            
            return sectionHeaderView
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellReusableResults, for: indexPath)
        
        if let word = wordModel {
            let translation = word.entries[indexPath.section].translations[indexPath.row]
            
            var content = UIListContentConfiguration.valueCell()
            content.text = translation.source
            content.textProperties.color = UIColor(named: K.AppColors.lightBlue) ?? .black
            content.secondaryText = translation.target
            content.prefersSideBySideTextAndSecondaryText = false
           
            cell.contentConfiguration = content
        }
        
        return cell
    }
}
