//
//  ViewController.swift
//  OpenAI
//
//  Created by Nikita Pishchugin on 07.03.23.
//

import UIKit
import OpenAISwift
import SPIndicator
import RealmSwift

class OnboardingVC: UIViewController {
    
    // MARK: - Private Properties
    private let openAI = OpenAIToken.openAI
    
    private let tapGestureRecognizer = UITapGestureRecognizer()
     
    // Views
    private let activityView = UIActivityIndicatorView(style: .medium)
    private var resultsView = ResultsView()
    private var searchView = SearchView()
    private var searchViewBottomAnchor: NSLayoutConstraint?
    
    private let keyboardOffSetValue: CGFloat = 20
    
    private var openAIResponse: String = ""
    
    // Realm
    private let realm = try! Realm()
    private let history = try! Realm().objects(History.self)

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "Color_Green")
        customNavigationBar()
        
        // Close the keyboard after user tap any view
        tapGestureRecognizer.addTarget(self, action: #selector(didTapView))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
        
        checkOpenAIAccessibility()
        
        setupSearchView()
        setupResultsView()
        
        // Move the searchView when keyboard appears and disappers
        registerForKeyboardNotifications()
    }
    
    // MARK: - Actions
    @objc private func didTapView() {
        searchView.searchTextField.text = ""
        view.endEditing(true)
    }
    
    @objc private func didTapHistoryButton() {
        let viewController = HistoryVC()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Private Functions
    private func checkOpenAIAccessibility(_ message: String = "Hello. How are you?" ) {
        openAI.sendCompletion(with: message) { results in
            switch results {
            case .success(let success):
                print(success.choices.first?.text ?? "")
            case .failure(let failure):
                print(failure.localizedDescription)
                DispatchQueue.main.async {
                    SPIndicator.present(title: "OpenAI is unavailable", preset: .error, haptic: .error)
                }
            }
        }
    }
    
    // ResultsView
    private func setupResultsView() {
        view.addSubview(resultsView.mainView)
        
        NSLayoutConstraint.activate([
            resultsView.mainView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            resultsView.mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            resultsView.mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            resultsView.mainView.bottomAnchor.constraint(equalTo: searchView.mainView.topAnchor, constant: -25)
        ])
    }
    
    // SearchView
    private func setupSearchView() {
        view.addSubview(searchView.mainView)
        
        searchView.searchTextField.delegate = self
        
        searchViewBottomAnchor = searchView.mainView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -keyboardOffSetValue)
        
        NSLayoutConstraint.activate([
            searchView.mainView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchView.mainView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            searchView.mainView.heightAnchor.constraint(equalToConstant: 45),
        ])
        
        guard let searchViewBottomAnchor = searchViewBottomAnchor else { return }
        searchViewBottomAnchor.isActive = true
    }
    
    // func which tracks when keyboard appears and disappears
    private func registerForKeyboardNotifications() {
        let showNotification = UIResponder.keyboardWillShowNotification
        NotificationCenter.default.addObserver(forName: showNotification, object: nil, queue: .main) { [weak self] notification in
            guard let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }
            self?.searchViewBottomAnchor?.constant = -(keyBoardSize.height + 10.0 )
            self?.navigationController?.setNavigationBarHidden(true, animated: true)
            
            UIView.animate(withDuration: 0) {
                self?.view.layoutIfNeeded()
            }
        }
        
        let hideNotification = UIResponder.keyboardWillHideNotification
        NotificationCenter.default.addObserver(forName: hideNotification, object: nil, queue: .main) { [weak self] _ in
            self?.searchViewBottomAnchor?.constant = -(self?.keyboardOffSetValue ?? 20.0)
            self?.navigationController?.setNavigationBarHidden(false, animated: true)
            
            UIView.animate(withDuration: 0) {
                self?.view.layoutIfNeeded()
            }
        }
    }

    // Activity indicator which appears during loading OpenAI data
    private func showActivityIndicator() {
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
    }
}

// MARK: - UITextFieldDelegate
extension OnboardingVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Info from resultsView disappears after pressing "enter"
        resultsView.textView.text = ""
        
        view.endEditing(true)
        
        // Activity indicator appears after press "enter"
        showActivityIndicator()
        
        openAI.sendCompletion(with: textField.text ?? "", maxTokens: 3000) { [weak self] results in
            switch results {
            case .success(let success):
                self?.openAIResponse = success.choices.first?.text ?? ""
                DispatchQueue.main.async { [weak self] in
                    
                    // Activity Indicator disappears after loading data
                    self?.activityView.stopAnimating()
                    self?.resultsView.textView.text = self?.openAIResponse
                    
                    // Create Realm Object
                    let historyElement = History(userQuestion: textField.text, openAIResponse: self?.openAIResponse)
                    
                    do {
                        try self?.realm.write {
                            self?.realm.add(historyElement)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    // Delete search text
                    textField.text = ""
                }
                print(self?.openAIResponse ?? "")
            case .failure(let failure):
                DispatchQueue.main.async { [weak self] in
                    self?.resultsView.textView.text = failure.localizedDescription
                    textField.text = ""
                }
            }
        }
        return true
    }
}

// MARK: - OnboardingVC
extension OnboardingVC {
    func customNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        navigationItem.title = "OpenAI"
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white as Any,
            .font: UIFont.systemFont(ofSize: 24)
        ]
        
        // Setup NavigationBar and remove bottom border
        navigationItem.standardAppearance = appearance
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        // Disable Back button
        navigationItem.setHidesBackButton(true, animated: true)
        
        // Custom Right Button
        let historyButton = UIButton()
        historyButton.setImage(UIImage(systemName: "book"), for: .normal)
        historyButton.tintColor = .white
        
        let rightButton = UIBarButtonItem(customView: historyButton)
        navigationItem.rightBarButtonItem = rightButton
        
        historyButton.addTarget(self, action: #selector(didTapHistoryButton), for: .touchUpInside)
    }
}
