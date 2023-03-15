//
//  HistoryVC.swift
//  OpenAI
//
//  Created by Nikita Pishchugin on 15.03.23.
//

import UIKit
import RealmSwift

class HistoryVC: UIViewController {
    
    // MARK: - Private Properties
    private let historyCollectionView = HistoryCollectionView()
    
    // Realm
    private let realm = try! Realm()
    private let history = try! Realm().objects(History.self)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "Color_Green")
        customNavigationBar()
        
        setupHistoryCollectionView()
    }
    
    // MARK: - Actions
    @objc private func didTapBackButton() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func didTapDeleteButton() {
        let alert = UIAlertController(title: "Delete All", message: "Are you sure you want to delete all history?", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] action in
            do {
                try self?.realm.write {
                    let allHistory = self?.realm.objects(History.self)
                    
                    guard let allHistory = allHistory else { return }
                    self?.realm.delete(allHistory)
                }
            } catch {
                print(error.localizedDescription)
            }
            self?.historyCollectionView.collectionView.reloadData()
        }
        let secondAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        present(alert, animated: true)
    }
    
    // MARK: - Private Functions
    private func setupHistoryCollectionView() {
        view.addSubview(historyCollectionView.collectionView)
        
        historyCollectionView.collectionView.delegate = self
        historyCollectionView.collectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            historyCollectionView.collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            historyCollectionView.collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            historyCollectionView.collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            historyCollectionView.collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension HistoryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return history.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = historyCollectionView.collectionView.dequeueReusableCell(withReuseIdentifier: CustomHistoryCollectionCell.reuseIdentifier, for: indexPath) as? CustomHistoryCollectionCell else {
            return UICollectionViewCell()
        }
        
        cell.setupCollectionCellValues(userQuestion: "\(indexPath.row + 1). \(history[indexPath.row].userQuestion ?? "") ",
                                       openAIResponse: history[indexPath.row].openAIResponse ?? "")
        return cell
    }
}

// MARK: - HistoryVC
private extension HistoryVC {
    func customNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        navigationItem.title = "History"
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 24)
        ]
        
        // Setup NavigationBar and remove bottom border
        navigationItem.standardAppearance = appearance
        
        // Disable Back button
//        navigationItem.setHidesBackButton(true, animated: true)
        
        // Custom Left Button
        let backButton = UIButton()
        backButton.setImage(UIImage(systemName: "arrowshape.backward"), for: .normal)
        backButton.tintColor = .white
        
        let leftButton = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = leftButton
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        // Custom Right Button
        let deleteButton = UIButton()
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .red
        
        if history.isEmpty {
            deleteButton.isHidden = true
        }
        
        let rightButton = UIBarButtonItem(customView: deleteButton)
        navigationItem.rightBarButtonItem = rightButton
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
    }
}
