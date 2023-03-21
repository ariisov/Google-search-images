//
//  Model.swift
//  GoogleSearchImages
//
//  Created by Булат Хатмуллин on 21.02.2023.
//

import Foundation

protocol CollectionViewUpdateDelegate: AnyObject {
    func update(result: [Result])
}

class Router {
    
    private var searchResults: [Result] = []
    
    weak var updateDelegate: CollectionViewUpdateDelegate?
    
    func createRequest(url: URL, Results: [Result]) {

        searchResults = Results
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
                print(self.searchResults)
                self.updateDelegate?.update(result: self.searchResults)
            }
        }
        task.resume()
        
    }
    
}
