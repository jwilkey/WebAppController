import UIKit
import WebKit

class WebAppViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!
    var webAppDelegate: WebAppDelegateProtocol?
    var bridgePrefix: String = "webapp:"
    var bridgeCommunicator: BridgeCommunicatorProtocol?
    
    var loadingView: UIView?
    var initialLoad: WKNavigation?

    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let delegate = webAppDelegate {
            if let loading = delegate.loadingView() {
                loadingView = loading
                loadingView?.frame = view.frame
                view.addSubview(loadingView!)
            }
            if let appPrefix = delegate.bridgePrefix?() {
                self.bridgePrefix = appPrefix
            }

            initialLoad = webView.load(URLRequest(url: delegate.baseUrl()))
        }
    }

    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        print(error)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString
        if (url?.hasPrefix(bridgePrefix)) ?? false {
            if let bridge = bridgeCommunicator {
                bridge.bridgeCommunication(url!)
            }
            decisionHandler(WKNavigationActionPolicy.cancel)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if navigation == initialLoad && loadingView != nil {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4, animations: {
                    self.loadingView?.layer.opacity = 0
                }, completion: { _ in
                    self.loadingView?.removeFromSuperview()
                    self.loadingView?.layer.opacity = 1
                })
            }
        }
    }
    
    // WKUIDelegate
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if (navigationAction.targetFrame == nil) {
            if let url = navigationAction.request.url {
                UIApplication.shared.openURL(url)
            }
        }
        return nil
    }
}

