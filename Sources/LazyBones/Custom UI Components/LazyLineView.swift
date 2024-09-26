import UIKit


open class LazyLineView: UIView {
    
    
    //----------------------------
    //  MARK: - Public Properties
    //----------------------------
    let orientation: Orientation
    let thickness: CGFloat
    
    
    
    //---------------
    //  MARK: - Init
    //---------------
    init(
        orientation: Orientation,
        color: UIColor = .black,
        thickness: CGFloat = 1.0 / UIScreen.main.scale
    ) {
        self.orientation = orientation
        self.thickness = thickness
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    
    
    //---------------------
    //  MARK: - Public API
    //---------------------
    enum Orientation {
        case horizontal, vertical
    }
    
    
    
    //----------------------
    //  MARK: - Private API
    //----------------------
    private func setup() {
        
        switch orientation {
        case .horizontal: heightAnchor.constraint(equalToConstant: thickness).isActive = true
        case .vertical: widthAnchor.constraint(equalToConstant: thickness).isActive = true
        }
    }
}
