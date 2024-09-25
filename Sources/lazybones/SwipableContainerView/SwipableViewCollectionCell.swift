import UIKit


class SwipableViewCollectionCell: UICollectionViewCell {
    

    //  MARK: - Internal Properties
    var hostedView: UIView? {
        didSet { setupHostedView() }
    }
    static let reuseID = "SWIPABLE_VIEW_COLLECTION_CELL"
    
    
    
    //  MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    
    
    //  MARK: - Private API
    private func setupCell() {
        
        backgroundColor = .clear
        contentView.clipsToBounds = false
        contentView.layer.masksToBounds = true
    }
    
    
    private func setupHostedView() {
        
        guard let hostedView = hostedView else { return }
        contentView.addSubview(hostedView)
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
