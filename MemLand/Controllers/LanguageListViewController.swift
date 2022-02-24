//
//  LanguageListViewController.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 30/1/22.
//

import UIKit

protocol LanguageListDelegate: NSObjectProtocol {
    func setSourceSelectedLanguage(_ language: LanguageModel)
    func setTargetSelectedLanguage(_ language: LanguageModel)
}

class LanguageListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: LanguageListDelegate?
    
    //var selectedLanguage: String?
    let languageManager = LanguageModelManager()
    var selectedModel: LanguageModel?
    var typeSelected: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }

}

//MARK: - UITableViewDataSource

extension LanguageListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageManager.languageModelList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellReusableLanguages, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.image = languageManager.languageModelList[indexPath.row].getImage()
        content.imageToTextPadding = 30
        content.text = languageManager.languageModelList[indexPath.row].name
        content.textProperties.font = UIFont.systemFont(ofSize: 20)
        content.textProperties.color = UIColor(named: K.AppColors.lightBlue) ?? .black
        cell.contentConfiguration = content
        
        if languageManager.languageModelList[indexPath.row] == selectedModel {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
}

extension LanguageListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let language = languageManager.languageModelList[indexPath.row]
        
        if typeSelected == "source" {
            self.delegate?.setSourceSelectedLanguage(language)
        } else if typeSelected == "target" {
            self.delegate?.setTargetSelectedLanguage(language)
        }
        
        navigationController?.popViewController(animated: true)
    }
}
