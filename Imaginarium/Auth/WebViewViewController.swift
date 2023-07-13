//
//  WebViewViewController.swift
//  Imaginarium
//
//  Created by Konstantin Penzin on 28.06.2023.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewConroller, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewConroller)
}

final class WebViewViewConroller: UIViewController {
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    weak var delegate: WebViewViewControllerDelegate?
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        guard var urlComponents = URLComponents(string: UnsplashAuthorizeURLString) else {
            fatalError("Incorrect Unsplash authorization base URL")
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AccessScope)
        ]
        
        guard let url = urlComponents.url else {
            fatalError("Unable to build authorization URL with components")
        }
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             changeHandler: { [weak self] _, _ in
            guard let self = self else {
                return
            }
            self.updateProgress()
        })
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    // MARK: - Actions
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

// MARK: - WKNavigationDelegate extension
extension WebViewViewConroller: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

