import SwiftUI
import WebKit
import SwiftSoup


struct WebView: UIViewRepresentable {
    
    var url: URL
    @ObservedObject var viewModel: ComparingClothesViewModel
    @Binding var showingWebView: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let wkwebview = WKWebView()
        wkwebview.navigationDelegate = context.coordinator
        return wkwebview
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, viewModel: _viewModel, showingWebView: $showingWebView)
    }
}

class Coordinator: NSObject, WKNavigationDelegate {
    
    @ObservedObject var viewModel: ComparingClothesViewModel
    @Binding var showingWebView: Bool
    
    var siteURLs = Set<String>()
    var parent: WebView
    init(_ parent: WebView,
         viewModel: ObservedObject<ComparingClothesViewModel>,
         showingWebView: Binding<Bool>) {
        _showingWebView = showingWebView
        _viewModel = viewModel
        self.parent = parent
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html, error) in
            if let htmlString = html as? String {
                do {
                    let doc: Document = try SwiftSoup.parse(htmlString)
                    var images = try doc.select("img").array()
                    var imageStrings = images.map({ try? $0.attr("src")})
                    imageStrings = imageStrings
                        .filter({$0?.hasPrefix("https") ?? false})
                        .filter({!($0?.contains(".png") ?? false)})
                        .map({ newValue in
                            if let safeString = newValue {
                                self.siteURLs.insert(safeString)
                                return safeString
                            } else {
                                return ""
                            }
                        })
                        
                    self.showingWebView = false
                } catch let error {
                    print("Error parsing HTML: \(error)")
                }
            }
        }
    }
    
    func getAllURL(imageURL: String ,onCompleted: @escaping () -> Void){
        self.siteURLs.insert(imageURL)
        onCompleted()
    }
}



