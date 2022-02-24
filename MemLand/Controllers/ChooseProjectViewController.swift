//
//  ChooseProjectViewController.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 2/2/22.
//

import UIKit
import RealmSwift

protocol ChooseProjectDelegate: NSObjectProtocol {
    func setChosenProject(_ project: ProjectModel)
}

class ChooseProjectViewController: UIViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: ChooseProjectDelegate?
    
    // TODO
    var projectSelected: ProjectModel?
    
    var modelManager = ModelManager()
    var projects: Results<ProjectModel>?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        // Projects
        projects = modelManager.loadProjects()
        tableView.reloadData()
        
        // UI
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addButtonPressed))
    }
    
    @objc func addButtonPressed(sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Project", message: "", preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Type a name"
            alertTextField.addTarget(alert, action: #selector(alert.textDidChangeInAlert), for: .editingChanged)
            textField = alertTextField
        }
        
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            
            let newProject = ProjectModel()
            newProject.name = textField.text!
            //We dont need to append the item to the list of categories becasuse the Results type does an autoupdate
            
            self.modelManager.saveProject(newProject)
            self.tableView.reloadData()
            
            // Once a project is created, it is chosen automatically
            self.delegate?.setChosenProject(newProject)
            self.navigationController?.popViewController(animated: true)
            
        }
        
        action.isEnabled = false
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension ChooseProjectViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellReusableProjects, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        if let project = projects?[indexPath.row] {
            content.text = project.name
            content.textProperties.font = UIFont.systemFont(ofSize: 20)
            content.textProperties.color = UIColor(named: K.AppColors.lightBlue) ?? .black
            
            cell.contentConfiguration = content
            
            if let selected = projectSelected {
                if selected.name == project.name {
                    cell.accessoryType = .checkmark
                }
            }
        }
        
        return cell
    }
}

extension ChooseProjectViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let project = projects?[indexPath.row] {
            delegate?.setChosenProject(project)
            navigationController?.popViewController(animated: true)
        }
    }
    
}
