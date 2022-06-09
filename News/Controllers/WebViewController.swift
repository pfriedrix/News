
import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    let webView = WKWebView()
    
    let urlString: String
    
    init (_ url: String) {
        urlString = url
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = view.bounds
        webView.navigationDelegate = self
        let url = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)

        webView.load(urlRequest)
        webView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        view.addSubview(webView)
    }
    

}
