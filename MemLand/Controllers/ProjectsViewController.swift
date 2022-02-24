//
//  ProjectsViewController.swift
//  MemLand
//
//  Created by Blanca Serrano Marfil on 15/2/22.
//

import UIKit

class ProjectsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noResultsProjects: UIImageView!
    
    
    // Collection variables
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(
      top: 10.0,
      left: 10.0,
      bottom: 10.0,
      right: 10.0)
    
    // Projects
    private var allProjects: [ProjectModel]?
    private let modelManager = ModelManager()
    
    private var projectSelected: ProjectModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        collectionView.reloadData()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func updateUI() {
        allProjects = modelManager.getAbsoluteProjects()
        collectionView.reloadData()
        if allProjects?.count == 0 {
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.noResultsProjects.isHidden = false
            })
        } else {
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.noResultsProjects.isHidden = true
            })
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == K.projectWordsSegue {
            let destinationVC = segue.destination as! ProjectWordsViewController
            destinationVC.projectSelected = projectSelected
        }
    }
}

extension ProjectsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allProjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.projectCollectionReusableCell, for: indexPath) as! ProjectCollectionViewCell
        
        // Data
        cell.projectNameLabel.text = allProjects?[indexPath.row].name ?? ""
        
        // UI
        cell.backgroundColor = UIColor(named: K.AppColors.lightGreen)
        cell.layer.cornerRadius = 10
        cell.projectNameLabel.textColor = .white
        
        return cell
    }
}

extension ProjectsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        projectSelected = allProjects?[indexPath.row]
        performSegue(withIdentifier: K.projectWordsSegue, sender: self)
    }
}

extension ProjectsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace - 40 //we need to take off 20 + 20 from the view constraints
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView.numberOfItems(inSection: section) == 1 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            flowLayout.scrollDirection = .vertical
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - 160)

        }
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
