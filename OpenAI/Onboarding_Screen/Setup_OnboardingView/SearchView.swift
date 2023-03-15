//
//  SearchView.swift
//  OpenAI
//
//  Created by Nikita Pishchugin on 07.03.23.
//

import UIKit

class SearchView: UIView {
    
    let mainView = UIView()
    let searchTextField = UISearchTextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        self.addSubview(mainView)
        mainView.addSubview(searchTextField)
        
        mainView.translateMask()
        searchTextField.translateMask()
        
        // SearchTextField
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Type something ..."
        )
        searchTextField.textAlignment = .left
        searchTextField.textColor = .black
        searchTextField.backgroundColor = .white
        searchTextField.layer.cornerRadius = 15
        
        // PlaceHolder Image
        let leftVeiwView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        searchTextField.leftView = leftVeiwView
        searchTextField.leftViewMode = .always
        let iconImage = UIImageView(frame: CGRect(x: 10, y:10, width: 22, height: 20))
        iconImage.tintColor = .black
        iconImage.image = UIImage(systemName: "magnifyingglass")
        leftVeiwView.addSubview(iconImage)
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            mainView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            mainView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            mainView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            
            searchTextField.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 0),
            searchTextField.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10),
            searchTextField.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -10),
            searchTextField.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 0)
        ])
    }
}
