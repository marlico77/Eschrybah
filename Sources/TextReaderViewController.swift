import UIKit

class TextReaderViewController: UIViewController {
    
    let fileURL: URL
    var textView: UITextView!
    
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
        
        textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.isEditable = true // Enable editing if they want to take notes inside txt
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        loadText()
        setupAnnotationMenu()
    }
    
    private var canvasView: AnnotationCanvasView?
    
    private func setupAnnotationMenu() {
        let optionsButton = UIBarButtonItem(title: "Opções", style: .plain, target: self, action: #selector(showOptionsMenu))
        navigationItem.rightBarButtonItem = optionsButton
    }
    
    @objc private func showOptionsMenu() {
        let alert = UIAlertController(title: "Ferramentas", message: "Escolha uma ação", preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Salvar Texto", style: .default) { _ in
            self.saveText()
        }
        
        let toggleDrawing = UIAlertAction(title: canvasView == nil ? "Grifar na Tela (Vidro)" : "Desligar Vidro", style: .default) { _ in
            self.toggleCanvas()
        }
        
        let clearDrawing = UIAlertAction(title: "Limpar Grifos", style: .destructive) { _ in
            self.canvasView?.clear()
        }
        
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(saveAction)
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
            textView.isScrollEnabled = true
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
            textView.isScrollEnabled = false
            
            let tip = UIAlertController(title: "Vidro Ativado", message: "A rolagem do texto foi travada para você poder desenhar por cima.", preferredStyle: .alert)
            tip.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(tip, animated: true, completion: nil)
        }
    }
    
    private func loadText() {
        do {
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            textView.text = text
        } catch {
            print("Failed to load text: \(error)")
            textView.text = "Erro ao carregar o arquivo ou o arquivo não é texto puro (UTF-8)."
        }
    }
    
    @objc private func saveText() {
        do {
            try textView.text.write(to: fileURL, atomically: true, encoding: .utf8)
            let alert = UIAlertController(title: "Salvo", message: "O arquivo foi atualizado.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } catch {
            print("Failed to save text: \(error)")
        }
    }
}
