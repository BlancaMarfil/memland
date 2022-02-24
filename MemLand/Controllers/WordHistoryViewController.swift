//
//  WordHistoryViewController.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 12/2/22.
//

import UIKit

class WordHistoryViewController: UIViewController {
    
    // Word
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var sourceImage: UIImageView!
    @IBOutlet weak var targetImage: UIImageView!
    
    // Trash Button
    @IBOutlet weak var deleteButton: UIButton!
    
    // Collection View
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Collection variables
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(
      top: 10.0,
      left: 10.0,
      bottom: 10.0,
      right: 10.0)
    
    // Vars
    internal var projectsFound: [String:Int] = [:]
    internal var translationSelected: TranslationModel? {
        didSet {
            if let translation = translationSelected {
                projectsFound = modelManager.getProjectAndCounterFromTranslation(translation)
            }
        }
    }
    internal var projectSelected: ProjectModel?
    
    // Managers
    private var modelManager = ModelManager()
    private var languageManager = LanguageModelManager()
    private var alertManager = AlertManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        alertManager.delegate = self
        
        // UI
        deleteButton.tintColor = .red
        setElementValues()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let translation = translationSelected else { return }
        projectsFound = modelManager.getProjectAndCounterFromTranslation(translation)
        collectionView.reloadData()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let alert = alertManager.createAlert(title: "Delete Word", message: "Are you sure you want to delete this word in all projects?")
        present(alert, animated: true, completion: nil)
    }
    
    func setElementValues() {
        if let translation = translationSelected {
            wordLabel.text = translation.word
            if let source = languageManager.getLanguageModel(byName: translation.sourceName) {
                sourceImage.image = source.getImage()
            } else {
                sourceImage.image = languageManager.getDefaultSourceLanguage().getImage()
            }
            
            if let target = languageManager.getLanguageModel(byName: translation.targetName) {
                targetImage.image = target.getImage()
            } else {
                targetImage.image = languageManager.getDefaultTargetLanguage().getImage()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.wordToProjectSegue {
            let destinationVC = segue.destination as! ProjectWordsViewController
            destinationVC.projectSelected = projectSelected
        }
    }
}

//MARK: - Alert Delegate
extension WordHistoryViewController: AlertManagerDelegate {
    func performAlertFunction() {
        guard let translation = translationSelected else { return }
        modelManager.deleteTranslationsFromAllProjects(translation)
        collectionView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Collection View Delegates

extension WordHistoryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return projectsFound.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.wordCollectionReusableCell, for: indexPath) as! WordHistoryCollectionViewCell
        
        // Data
        cell.projectTitleLabel.text = Array(projectsFound)[indexPath.row].key
        cell.timesSearchedLabel.text = "\(Array(projectsFound)[indexPath.row].value)"
        
        // UI
        cell.backgroundColor = UIColor(named: K.AppColors.lightGreen)
        cell.layer.cornerRadius = 10
        cell.projectTitleLabel.textColor = .white
        cell.timesSearchedLabel.textColor = .white
        
        return cell
    }
}

extension WordHistoryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        projectSelected = modelManager.findProject(byName: Array(projectsFound)[indexPath.row].key)
        performSegue(withIdentifier: K.wordToProjectSegue, sender: self)
    }
}

extension WordHistoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace - 40 //we need to take off 20 + 20 from the view constraints
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView.numberOfItems(inSection: section) == 1 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)

        }
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
