import UIKit


open class GradientView: UIView {
    
    
    //----------------------------
    //  MARK: - Public Properties
    //----------------------------
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    
    //-----------------------------
    //  MARK: - Private Properties
    //-----------------------------
    private let colors: [CGColor]
    private let direction: GradientDirection
    private var didLayoutSubviews = false
    
    
    
    //---------------
    //  MARK: - Init
    //---------------
    public init(
        colors: [UIColor],
        direction: GradientDirection = .leftToRight
    ) {
        self.colors = colors.map { $0.cgColor }
        self.direction = direction
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    
    
    //-------------------------------
    //  MARK: - Superclass Overrides
    //-------------------------------
    open override func layoutSubviews() {
        super.layoutSubviews()
        if didLayoutSubviews { return }
        setupGradient()
        didLayoutSubviews = true
    }
    
    
    
    //---------------------
    //  MARK: - Private API
    //----------------------
    private func setupGradient() {

        layer.addSublayer(gradientLayer)
        gradientLayer.colors = colors
        gradientLayer.frame = bounds
        gradientLayer.startPoint = direction.startPoint
        gradientLayer.endPoint = direction.endPoint
    }
}
