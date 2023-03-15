//
//  ResultsView.swift
//  OpenAI
//
//  Created by Nikita Pishchugin on 10.03.23.
//

import UIKit

class ResultsView: UIView {
    
    let mainView = UIView()
    let textView = UITextView()
    
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
        mainView.addSubview(textView)
        
        mainView.translateMask()
        textView.translateMask()
        
        mainView.backgroundColor = .white
        
        textView.isEditable = false
        textView.textColor = .black
        textView.font = .systemFont(ofSize: 16)
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: self.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            textView.topAnchor.constraint(equalTo: mainView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
        ])
    }
}
