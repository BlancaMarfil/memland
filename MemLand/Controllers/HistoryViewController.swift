//
//  HistoryViewController.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 9/2/22.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController {

    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noResultsImage: UIImageView!
    
    // User Defaults
    let userDefaults = UserDefaults.standard
    
    // Table info
    private var allTranslations: [TranslationModel]?
    private var selectedTranslation: TranslationModel?
    
    // Managers
    private var modelManager = ModelManager()
    private var languageModelManager = LanguageModelManager()
    private var alertManager = AlertManager()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.cellHistoryNibName, bundle: nil), forCellReuseIdentifier: K.cellReusableHistory)
        
        tableView.dataSource = self
        tableView.delegate = self
        alertManager.delegate = self
        
        // UI
        clearButton.tintColor = .systemRed
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func updateUI() {
        allTranslations = modelManager.getTranslations()
        tableView.reloadData()
        if allTranslations?.count == 0 {
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.noResultsImage.isHidden = false
            })
        } else {
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.noResultsImage.isHidden = true
            })
        }
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        let alert = alertManager.createAlert(title: "Delete Search History", message: "Are you sure you want to delete all your search history?")
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == K.wordHistorySegue {
            let destinationVC = segue.destination as! WordHistoryViewController
            if let translation = selectedTranslation {
                destinationVC.translationSelected = translation
            }
        }
    }
}

//MARK: - Alert Delegate
extension HistoryViewController: AlertManagerDelegate {
    func performAlertFunction() {
        self.modelManager.deleteAllTranslations()
        self.userDefaults.set(K.Defaults.projectName, forKey: K.UserDefaultsVariables.projectSelected)
        updateUI()
    }
}

//MARK: - TableView Delegates

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTranslations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellReusableHistory, for: indexPath) as! HistoryCell
        
        if let translations = allTranslations {
            
            let t = translations[indexPath.row]
            
            // Flags
            let sourceLanguage = languageModelManager.getLanguageModel(byName: t.sourceName)
            let targetLanguage = languageModelManager.getLanguageModel(byName: t.targetName)
            cell.sourceImage.image = sourceLanguage?.getImage()
            cell.targetImage.image = targetLanguage?.getImage()
            
            // Word
            cell.wordLabel.text = t.word
            
            // Project
            var parentProjectSearched: ProjectModel?
            
            for parent in t.parentProject {
                parentProjectSearched = parent
            }
            
            if let parentProjectFound = parentProjectSearched {
                if parentProjectFound.name == K.Defaults.projectName {
                    cell.projectNameView.isHidden = true
                } else {
                    cell.projectNameLabel.text = parentProjectFound.name
                    cell.projectNameView.isHidden = false
                }
            } else {
                cell.projectNameView.isHidden = true
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let translations = allTranslations {
            selectedTranslation = translations[indexPath.row]
            performSegue(withIdentifier: K.wordHistorySegue, sender: self)
        }
    }

}
