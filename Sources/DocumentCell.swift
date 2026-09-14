import UIKit

class DocumentCell: UICollectionViewCell {
    
    let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .systemBlue
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16 // Mais arredondado
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.15
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 8
        contentView.layer.masksToBounds = false // Para garantir que a sombra apareça fora do cornerRadius
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with url: URL) {
        titleLabel.text = url.lastPathComponent
        
        // Basic icon assignment based on extension
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "pdf":
            iconImageView.image = UIImage(named: "pdf_icon") // Fallback logic below if image missing
        case "epub":
            iconImageView.image = UIImage(named: "epub_icon")
        case "txt", "md", "csv", "json":
            iconImageView.image = UIImage(named: "txt_icon")
        case "docx", "doc":
            iconImageView.image = UIImage(named: "word_icon")
        default:
            iconImageView.image = UIImage(named: "generic_icon")
        }
        
        // Since we don't have assets yet, let's use a generic colored view or shape if image is nil
        if iconImageView.image == nil {
            iconImageView.backgroundColor = .lightGray
            iconImageView.layer.cornerRadius = 4
        } else {
            iconImageView.backgroundColor = .clear
        }
    }
}
