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
    
    private func setupAnnotationMenu() {
        let optionsButton = UIBarButtonItem(title: "Opções", style: .plain, target: self, action: #selector(showOptionsMenu))
        navigationItem.rightBarButtonItem = optionsButton
    }
    
    @objc private func showOptionsMenu() {
        let alert = UIAlertController(title: "Ferramentas", message: "Escolha uma ação", preferredStyle: .actionSheet)
        
        let toggleDrawing = UIAlertAction(title: canvasView == nil ? "Grifar na Tela (Vidro)" : "Desligar Vidro", style: .default) { _ in
            self.toggleCanvas()
        }
        
        let clearDrawing = UIAlertAction(title: "Limpar Grifos", style: .destructive) { _ in
            self.canvasView?.clear()
        }
        
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(toggleDrawing)
        if canvasView != nil {
            alert.addAction(clearDrawing)
        }
        alert.addAction(cancel)
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func toggleCanvas() {
        if let canvas = canvasView {
            canvas.removeFromSuperview()
            canvasView = nil
            webView.scrollView.isScrollEnabled = true
        } else {
            let canvas = AnnotationCanvasView(frame: .zero)
            canvas.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(canvas)
            
            NSLayoutConstraint.activate([
                canvas.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            canvasView = canvas
            webView.scrollView.isScrollEnabled = false
            
            let tip = UIAlertController(title: "Vidro Ativado", message: "A rolagem foi travada para você poder desenhar por cima.", preferredStyle: .alert)
            tip.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(tip, animated: true, completion: nil)
        }
    }
}
