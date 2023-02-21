//
//  ImageSearchViewController.swift
//  GoogleSearchImages
//
//  Created by Булат Хатмуллин on 21.02.2023.
//

import Foundation
import UIKit

// MARK: - ImageSearchViewController

class ImageSearchViewController: UIViewController {
    
    var searchResults: [Result] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .gray
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        return collectionView
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Hedgehog"
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        title = "Search Images"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        performSearch(query: "Hedgehog")
    }
    
    
    
    private func performSearch(query: String) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let serpapiLink = "https://serpapi.com/search"
        let apiKey = "a30e0a96b28ff462b1665630db01456304df3b22d20c1c8c5f602f1d0af7ad3a"
        let urlString = "\(serpapiLink)?q=\(encodedQuery)&tbm=isch&api_key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data else { return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
            guard let images = json["images_results"] as? [[String: Any]] else { return }
            let urls = images.compactMap { $0["original"] as? String }.compactMap { URL(string: $0) }
            let links = images.compactMap { $0["link"] as? String }.compactMap { URL(string: $0) }
            
            DispatchQueue.main.async {
                self.searchResults.removeAll()
                for imageIndex in 0..<urls.count-1 {
                    self.searchResults.append(Result(imageURL: urls[imageIndex], sourceURL: links[imageIndex]))
                }
                self.collectionView.reloadData()
            }
        }
        task.resume()
    }
    
    // MARK: - Navigation Methods
    
    private func showImage(at index: Int) {
        let imageUrl = searchResults[index].imageURL
        let imageViewController = ImageViewController(imageUrl: imageUrl, searchResults: searchResults)
        navigationController?.pushViewController(imageViewController, animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource

extension ImageSearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as! ImageCell
        let imageUrl = searchResults[indexPath.row].imageURL
        cell.imageView.setImage(with: imageUrl)
        
        return cell
    }
    
}

extension ImageSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showImage(at: indexPath.row)
    }
}


extension ImageSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.bounds.width - 24) / 2
        return CGSize(width: width, height: width)
    }
}

extension ImageSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            searchResults = []
            collectionView.reloadData()
            return
        }
        performSearch(query: query)
    }
}

extension ImageSearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        performSearch(query: "Hedgehog")
    }
}
