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
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveText))
        navigationItem.rightBarButtonItem = saveButton
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
