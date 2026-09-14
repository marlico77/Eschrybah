import UIKit
import WebKit

class EpubReaderViewController: UIViewController {
    
    let fileURL: URL
    var webView: WKWebView!
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = fileURL.lastPathComponent
        
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // For actual ePub, we'd use a parser to unzip and get the HTML chapters.
        // For now, we load it if it's an HTML file, or show a placeholder message.
        if fileURL.pathExtension.lowercased() == "epub" {
            let htmlString = """
            <html>
            <head><style>body { font-family: -apple-system; font-size: 40px; padding: 40px; }</style></head>
            <body>
            <h2>Leitor de ePub</h2>
            <p>O arquivo \(fileURL.lastPathComponent) foi aberto.</p>
            <p>Para renderizar ePubs complexos nativamente, um descompactador zip (como ZipFoundation) será integrado na fase 2 para extrair os arquivos HTML de dentro do ePub e exibi-los aqui.</p>
            </body>
            </html>
            """
            webView.loadHTMLString(htmlString, baseURL: nil)
        } else {
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }
        
        setupAnnotationMenu()
    }
    
    private var canvasView: AnnotationCanvasView?
    private var floatingMenu: FloatingMenuButton!
    
    private func setupAnnotationMenu() {
        navigationItem.rightBarButtonItem = nil
        setupFloatingMenu()
    }
    
    private func setupFloatingMenu() {
        floatingMenu = FloatingMenuButton()
        floatingMenu.delegate = self
        view.addSubview(floatingMenu)
    }
}

extension EpubReaderViewController: FloatingMenuDelegate {
    func didSelectTool(color: UIColor, width: CGFloat) {
        canvasView?.drawingColor = color
        canvasView?.drawingWidth = width
    }
    
    func didSelectClear() {
        canvasView?.clear()
    }
    
    func didToggleCanvas(isActive: Bool) {
        if isActive {
            let canvas = AnnotationCanvasView(frame: .zero)
            canvas.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(canvas, belowSubview: floatingMenu)
            
            NSLayoutConstraint.activate([
                canvas.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            canvasView = canvas
            webView.scrollView.isScrollEnabled = false
        } else {
            canvasView?.removeFromSuperview()
            canvasView = nil
            webView.scrollView.isScrollEnabled = true
        }
    }
}
