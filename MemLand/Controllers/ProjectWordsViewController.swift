//
//  ProjectWordsViewController.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 15/2/22.
//

import UIKit

class ProjectWordsViewController: UIViewController {
    
    @IBOutlet weak var projectNameLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    // User Defaults
    let userDefaults = UserDefaults.standard
    
    // Managers
    private let modelManager = ModelManager()
    private let languageManager = LanguageModelManager()
    private var alertManager = AlertManager()
    
    // Models
    private var allSections: [(String,String)]?
    
    internal var projectSelected: ProjectModel? {
        didSet {
            if let project = projectSelected {
                allSections = project.getDifferentTypesOfTranslations()
            }
        }
    }
    private var translationSelected: TranslationModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        alertManager.delegate = self
        
        // UI
        editButton.tintColor = UIColor(named: K.AppColors.lightGreen)
        deleteButton.tintColor = .systemRed
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    func updateUI() {
        projectNameLabel.text = projectSelected?.name ?? ""
        self.tableView.reloadData()
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Change Project Name", message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.text = self.projectSelected?.name ?? ""
            alertTextField.placeholder = "Type a name"
            alertTextField.addTarget(alert, action: #selector(alert.textDidChangeInAlert), for: .editingChanged)
            textField = alertTextField
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        
        // Change action
        let action = UIAlertAction(title: "Change", style: .default) { action in
            if let project = self.projectSelected {
                self.projectSelected =  self.modelManager.updateProjectName(project: project, newName: textField.text!)
                self.updateUI()
            }
        }
        action.isEnabled = false
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        let alert = alertManager.createAlert(title: "Delete Project", message: "Are you sure you want to delete this project?")
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.projectWordToHistoryWordSegue {
            let destinationVC = segue.destination as! WordHistoryViewController
            destinationVC.translationSelected = translationSelected
        }
    }
    
}

//MARK: - Alert Delegate
extension ProjectWordsViewController: AlertManagerDelegate {
    func performAlertFunction() {
        guard let project = projectSelected else { return }
        modelManager.deleteProject(project)
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Table View Delegates

extension ProjectWordsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allSections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfrows: Int?
        
        if let sections = allSections {
            let sectionToShow = sections[section]
            numberOfrows = projectSelected?.getTranslationsFor(source: sectionToShow.0, target: sectionToShow.1).count
        }
        return numberOfrows ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellReusableProjectWords, for: indexPath)
        
        if let project = projectSelected, let sections = allSections {
            let translations = project.getTranslationsFor(source: sections[indexPath.section].0, target: sections[indexPath.section].1)
            
            var content = UIListContentConfiguration.valueCell()
            content.text = translations[indexPath.row].word
            content.textProperties.color = UIColor(named: K.AppColors.lightBlue) ?? .black
            
            content.secondaryText = "\(translations[indexPath.row].counter)"
            content.secondaryTextProperties.font = .boldSystemFont(ofSize: 18)
            content.secondaryTextProperties.color = UIColor(named: K.AppColors.lightGreen) ?? .green
            
            cell.contentConfiguration = content
        }
        
        return cell
    }
}
    
extension ProjectWordsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 || self.tableView(tableView, viewForHeaderInSection: section) == nil {
            return 0
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let sections = allSections {
            let sectionHeaderView = UIView()
            var stackView = UIStackView()
            
            let sourceLanguage = languageManager.getLanguageModel(byName: sections[section].0)
            let targetLanguage = languageManager.getLanguageModel(byName: sections[section].1)
            
            let sourceImage = sourceLanguage?.getImage()
            let targetImage = targetLanguage?.getImage()
            
            if let sourceIm = sourceImage, let targetIm = targetImage {
                
                let viewArray = [UIImageView(image: sourceIm), UIImageView(image: UIImage(systemName: "arrow.right")), UIImageView(image: targetIm)]
                stackView = UIStackView(arrangedSubviews: viewArray)
                stackView.translatesAutoresizingMaskIntoConstraints = false
                stackView.axis = .horizontal
                stackView.spacing = 16
                stackView.distribution = .fillProportionally
                
                sectionHeaderView.addSubview(stackView)
                
                let leading = NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: sectionHeaderView, attribute: .leading, multiplier: 1.0, constant: 10)
                sectionHeaderView.addConstraint(leading)
                
                let bottom = NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: sectionHeaderView, attribute: .bottom, multiplier: 1.0, constant: -10)
                sectionHeaderView.addConstraint(bottom)
                
                leading.isActive = true
                bottom.isActive = true
            }
            return sectionHeaderView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let project = projectSelected, let sections = allSections {
            let translations = project.getTranslationsFor(source: sections[indexPath.section].0, target: sections[indexPath.section].1)
            translationSelected = translations[indexPath.row]
            performSegue(withIdentifier: K.projectWordToHistoryWordSegue, sender: self)
        }
    }
}
