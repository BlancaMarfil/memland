//
//  ChooseLanguageViewController.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 27/1/22.
//

import UIKit

protocol ChooseLanguageDelegate: NSObjectProtocol {
    func setChosenLanguages(source: LanguageModel, target: LanguageModel)
}

class ChooseLanguageViewController: UIViewController {
    
    // weak var for the delegate is to avoid retain cycle (both source view controller and destination view controller has a strong reference to each other, causing ARC to not free the memory)
    // if it's weak, it must be optional
    weak var delegate: ChooseLanguageDelegate?

    // Buttons
    @IBOutlet weak var chooseSourceButton: UIButton!
    @IBOutlet weak var chooseTargetButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    
    // Flags Images
    @IBOutlet weak var sourceImage: UIImageView!
    @IBOutlet weak var targetImage: UIImageView!
    
    // Internal variables
    internal var sourceLanguage: LanguageModel?
    internal var targetLanguage: LanguageModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chooseSourceButton.tintColor = UIColor(named: K.AppColors.lightGreenOpacity)
        chooseTargetButton.tintColor = UIColor(named: K.AppColors.lightGreenOpacity)
        okButton.tintColor = UIColor(named: K.AppColors.lightBlue)
        
        // Initializers
        setElementValues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.topItem!.title = K.NavigationControllersTitles.chooseLanguagesTitle
    }
    
    func setElementValues() {
        if let sourceLan = sourceLanguage, let targetLan = targetLanguage {
            chooseSourceButton.setTitle(sourceLan.name, for: .normal)
            chooseTargetButton.setTitle(targetLan.name, for: .normal)
            sourceImage.image = sourceLan.getImage()
            targetImage.image = targetLan.getImage()
        }
    }
    
    //MARK: - Buttons
    
    @IBAction func changeSourceButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: K.listSourceLanguageSegue, sender: self)
    }
    
    @IBAction func changeTargetButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: K.listTargetLanguageSegue, sender: self)
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        if sourceLanguage == targetLanguage {
            let alert = UIAlertController(title: "Choose Languages", message: "Source and Target languages cannot be the same.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
        } else {
            if let source = sourceLanguage, let target = targetLanguage {
                delegate?.setChosenLanguages(source: source, target: target)
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! LanguageListViewController
        destinationVC.delegate = self
        
        if segue.identifier == K.listSourceLanguageSegue {
            destinationVC.selectedModel = sourceLanguage
            destinationVC.typeSelected = "source"
        } else if segue.identifier == K.listTargetLanguageSegue {
            destinationVC.selectedModel = targetLanguage
            destinationVC.typeSelected = "target"
        }
    }
}

//MARK: - LanguageListDelegate

extension ChooseLanguageViewController: LanguageListDelegate {
    func setSourceSelectedLanguage(_ language: LanguageModel) {
        sourceLanguage = language
        setElementValues()
    }
    
    func setTargetSelectedLanguage(_ language: LanguageModel) {
        targetLanguage = language
        setElementValues()
    }
}
