//
//  HistoryCollectionView.swift
//  OpenAI
//
//  Created by Nikita Pishchugin on 15.03.23.
//

import UIKit

// MARK: - HistoryCollectionView
class HistoryCollectionView: UIView {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        self.addSubview(collectionView)
        collectionView.translateMask()
        collectionView.backgroundColor = CustomColors.colorVanilla
        collectionView.isScrollEnabled = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
        
        // Register new custom CollectionViewCell
        collectionView.register(CustomHistoryCollectionCell.self, forCellWithReuseIdentifier: CustomHistoryCollectionCell.reuseIdentifier)
        
        // Set new collectionView layout
        collectionView.setCollectionViewLayout(generateHistoryCollectionLayout(), animated: true)
    }
    
    private func generateHistoryCollectionLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (section, layoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = .init(top: 0, leading: 0, bottom: 50, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(self.collectionView.frame.height))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
            group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            return section
        }
    }
}

// MARK: - CustomHistoryCollectionCell
class CustomHistoryCollectionCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: CustomHistoryCollectionCell.self)
    
    let mainView = UIView()
    let userQuestionTextView = UITextView()
    let openAIResponseTextView = UITextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func prepareForReuse() {
        userQuestionTextView.text = nil
        openAIResponseTextView.text = nil
    }
    
    func setupCollectionCellValues(userQuestion: String?, openAIResponse: String?) {
        userQuestionTextView.text = userQuestion
        openAIResponseTextView.text = openAIResponse
    }
    
    private func setupUI() {
        contentView.addSubview(mainView)
        mainView.addSubview(userQuestionTextView)
        mainView.addSubview(openAIResponseTextView)
        
        mainView.translateMask()
        userQuestionTextView.translateMask()
        openAIResponseTextView.translateMask()
                
        userQuestionTextView.textAlignment = .left
        userQuestionTextView.textColor = .black
        userQuestionTextView.backgroundColor = CustomColors.colorVanilla
        userQuestionTextView.font = UIFont(name: CustomFonts.sourceSansProSemiBold, size: 20)
//        userQuestionTextView.isEditable = false
        
        openAIResponseTextView.textAlignment = .left
        openAIResponseTextView.textColor = .black
        openAIResponseTextView.backgroundColor = CustomColors.colorVanilla
        openAIResponseTextView.font = UIFont(name: CustomFonts.sourceSansProRegular, size: 16)
        openAIResponseTextView.isEditable = false
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: self.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            userQuestionTextView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 0),
            userQuestionTextView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10),
            userQuestionTextView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            userQuestionTextView.heightAnchor.constraint(equalToConstant: 50),
            
            openAIResponseTextView.topAnchor.constraint(equalTo: userQuestionTextView.bottomAnchor, constant: 0),
            openAIResponseTextView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10),
            openAIResponseTextView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            openAIResponseTextView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 0)
        ])
    }
}
