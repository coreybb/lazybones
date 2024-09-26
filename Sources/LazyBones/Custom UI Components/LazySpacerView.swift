import UIKit


open class LazySpacerView: UIView {
    

    //  MARK: - Public Properties
    let width: CGFloat?
    let height: CGFloat?
    
    

    //  MARK: - Init
    public init(
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) {
        self.width = width
        self.height = height
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layoutUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    
    
    //  MARK: - Private API
    private func layoutUI() {
        
        if let width: CGFloat {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height: CGFloat {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
