import UIKit


/// A base class for creating custom `UIButton` subclasses that replicates the `isHighlighted` functionality of `ButtonType.system` when a custom initializer is required.
open class LazyButton: UIButton {
    
    
    //  MARK: - Public Properties
    public override var isHighlighted: Bool {
        
        get { return super.isHighlighted }
        
        set {
            guard newValue != isHighlighted else { return }

            if newValue == true {
                titleLabel?.alpha = 0.25
                imageView?.tintColor = imageView?.tintColor.withAlphaComponent(0.4)
            } else {
                UIView.animate(withDuration: 0.2) {
                    [unowned self] in
                    titleLabel?.alpha = 1
                    imageView?.tintColor = imageView?.tintColor.withAlphaComponent(1)
                }
                super.isHighlighted = newValue
            }

            super.isHighlighted = newValue
        }
    }


    //  MARK: - Private Properties
    private var _didLayoutSubviews: Bool = false
    
    

    //  MARK: - Init
    public init(
        textStyle: (any LazyContentStyle)?,
        title: String? = nil,
        backgroundColor: UIColor? = nil,
        action: (() -> ())? = nil
    ) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: .normal)
        self.setTitleColor(textStyle?.textColor, for: .normal)
        self.titleLabel?.font = textStyle?.font
        self.backgroundColor = backgroundColor
        if let action {
            addAction { _ in
               action()
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    
    
    //  MARK: - Superclass Overrides
    override open func layoutSubviews() {
        super.layoutSubviews()
        if _didLayoutSubviews { return }
        didLayoutSubviews()
        _didLayoutSubviews = true
    }
    
    
    //  MARK: - Internal API
    /// An empty method to be overridden for performing any setup that must run after the `UIButton` superclass has laid out its subviews.
    internal func didLayoutSubviews() { }
}

