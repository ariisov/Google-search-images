//
//  ImageViewController.swift
//  GoogleSearchImages
//
//  Created by Булат Хатмуллин on 21.02.2023.
//

import Foundation
import UIKit

// MARK: - Result

struct Result {
    let imageURL: URL
    let sourceURL: URL
}

// MARK: - ImageSearchViewController

class ImageViewController: UIViewController {
    
    private let imageUrl: URL
    
    private var searchResults: [Result] = []
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let prevButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let sourceButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var openSourceLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Open source page"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    
    private var currentIndex: Int = 0
    
    init(imageUrl: URL, searchResults: [Result]) {
        self.imageUrl = imageUrl
        self.searchResults = searchResults
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        imageView.setImage(with: imageUrl)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        ])
        
        view.addSubview(nextButton)
        NSLayoutConstraint.activate([
            nextButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        nextButton.addTarget(self, action: #selector(showNextImage), for:.touchUpInside)
        
        view.addSubview(prevButton)
        NSLayoutConstraint.activate([
            prevButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            prevButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        prevButton.addTarget(self, action: #selector(showPreviousImage), for: .touchUpInside)
        
        sourceButton.setTitleColor(.blue, for: .normal)
        view.addSubview(sourceButton)
        NSLayoutConstraint.activate([
            
            sourceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            sourceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        sourceButton.addTarget(self, action: #selector(openSourcePage), for: .touchUpInside)
        
        
        
        view.addSubview(openSourceLabel)
        
        NSLayoutConstraint.activate([
            openSourceLabel.topAnchor.constraint(equalTo: sourceButton.topAnchor, constant: 10),
            openSourceLabel.leadingAnchor.constraint(equalTo: sourceButton.leadingAnchor, constant: 10),
            openSourceLabel.trailingAnchor.constraint(equalTo: sourceButton.trailingAnchor, constant: -10),
            openSourceLabel.bottomAnchor.constraint(equalTo: sourceButton.bottomAnchor, constant: -10)
        ])
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(showPreviousImage))
        swipeRight.direction = .right
        imageView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(showNextImage))
        swipeLeft.direction = .left
        imageView.addGestureRecognizer(swipeLeft)
    }
    
    @objc private func showNextImage() {
        guard currentIndex + 1 < searchResults.count else {
            return
        }
        currentIndex += 1
        imageView.setImage(with: searchResults[currentIndex].imageURL)
    }
    
    @objc private func showPreviousImage() {
        guard currentIndex > 0 else {
            return
        }
        currentIndex -= 1
        imageView.setImage(with: searchResults[currentIndex].imageURL)
    }
    
    @objc private func openSourcePage() {
        let webViewVC = WebViewController(url: searchResults[currentIndex].sourceURL)
        navigationController?.pushViewController(webViewVC, animated: true)
    }

}

extension UIImageView {
    
    func setImage(with url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            DispatchQueue.main.async {
                self.image = image
            }
        }
        task.resume()
    }
}
