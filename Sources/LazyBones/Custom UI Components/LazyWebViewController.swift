import UIKit
import WebKit

open class LazyWebViewController: UIViewController {
    
    
    //  MARK: - Public Properties
    public let webView: WKWebView = WKWebView()
    public let url: URL
    

    
    
    //---------------
    //  MARK: - Init
    //---------------
    public init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .automatic
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    
    //-------------------------------
    //  MARK: - Superclass Overrides
    //-------------------------------
    public override func loadView() {
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        view = webView
    }
}
