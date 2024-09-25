import UIKit


open class LazyGradientLabel: GradientView {
    
    
    //  MARK: - Public Properties
    let text: String
    let style: (any LazyContentStyle)?
    let alignment: NSTextAlignment
    
    
    
    //  MARK: - Private Propeties
    private var didLayoutSubviews: Bool = false
    
    
    
    //  MARK: - Init
    public init(
        style: (any LazyContentStyle)? = nil,
        text: String,
        colors: [UIColor],
        gradientDirection: GradientDirection = .leftToRight,
        textAlignment: NSTextAlignment = .center
    ) {
        self.style = style
        self.text = text
        self.alignment = textAlignment
        super.init(colors: colors, direction: gradientDirection)
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    
    
    //  MARK: - Superclass Overrides
    open override func layoutSubviews() {
        super.layoutSubviews()
        if didLayoutSubviews { return }
        setupLabel()
        didLayoutSubviews = true
    }
    
    

    //  MARK: - Private API
    private func setupLabel() {
        
        let label: UILabel = UILabel(frame: bounds)
        label.text = text
        label.font = style?.font
        label.textAlignment = alignment
        addSubview(label)
        mask = label
    }
}
