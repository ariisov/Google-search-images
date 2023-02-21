//
//  WebViewController.swift
//  GoogleSearchImages
//
//  Created by Булат Хатмуллин on 21.02.2023.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController {
    
    private let webView = WKWebView()
    private let url = URL(string: "")
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        webView.load(URLRequest(url: url))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = webView
    }
}
