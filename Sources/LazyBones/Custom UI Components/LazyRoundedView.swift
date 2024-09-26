import UIKit


/// A `UIView` subclass whose rounded corners represent a more "native-to-iOS"  design aesthetic.
/// Note that changes to its `backgroundColor` are ignored, and must be made using its `backgroundColorForView` property.
open class LazyRoundedView: UIView {
    
    
    //----------------------------
    //  MARK: - Public Properties
    //----------------------------
    /// The property value that must be modified to change the `backgroundColor`.
    lazy var backgroundColorForView: UIColor = .lightGray {
        didSet { shapeView.backgroundColor = backgroundColorForView }
    }

    
    
    //-----------------------------
    //  MARK: - Private Properties
    //-----------------------------
    private lazy var shapeView: SquircleShapeView = SquircleShapeView(cornerRadius)
    private let cornerRadius: CGFloat
    private var didLayoutSubviews = false
    
    

    //---------------
    //  MARK: - Init
    //---------------
    public init(cornerRadius: CGFloat = 16) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        backgroundColor = .clear
        layoutUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }

    
    
    
    //  MARK: - Superclass Overrides
    open override func layoutSubviews() {
        super.layoutSubviews()
        if didLayoutSubviews { return }
        layer.cornerRadius = cornerRadius
        didLayoutSubviews = true
    }


    
    //----------------------
    //  MARK: - Private API
    //----------------------
    private func layoutUI() {
        
        let padding: CGFloat = 0.0
        
        addSubview(shapeView)
        shapeView.fillSuperview(
            padding: UIEdgeInsets(
                top: padding,
                left: padding,
                bottom: padding,
                right: padding
            )
        )
    }
}



class SquircleShapeView: UIView {

    
    //-----------------------------
    //  MARK: - Private Properties
    //-----------------------------
    private let cornerRadius: CGFloat
    private lazy var maskLayer: CAShapeLayer = {
        layer.mask = $0
        return $0
    }(CAShapeLayer())
    
    
    
    //---------------
    //  MARK: - Init
    //---------------
    init(_ cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    

    //-------------------------------
    //  MARK: - Superclass Overrides
    //-------------------------------
    public override var bounds: CGRect {
        set { setBounds(with: newValue) }
        get { return super.bounds }
    }
    
    
    
    //-----------------------
    //  MARK: - Private API
    //-----------------------
    private func setBounds(with newValue: CGRect) {

        super.bounds = newValue
        maskLayer.frame = newValue
        let newPath: CGPath = UIBezierPath(roundedRect: newValue, cornerRadius: cornerRadius).cgPath
        let key: String = "bounds.size"
        
        guard let animation: CABasicAnimation = layer.animation(forKey: key)?.copy() as? CABasicAnimation else {
            maskLayer.path = newPath
            maskLayer.masksToBounds = false
            return
        }
        
        let path: String = "path"
        animation.keyPath = path
        animation.fromValue = maskLayer.path
        animation.toValue = newPath
        maskLayer.path = newPath
        maskLayer.add(animation, forKey: path)
    }
}
