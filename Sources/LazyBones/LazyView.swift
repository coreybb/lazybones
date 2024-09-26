import UIKit


open class LazyView: UIView {
    
    
    public private(set) var didLayoutSubviews = false
 
    
    init(
        color: UIColor? = nil,
        usesAutolayout: Bool = false
    ) {
        super.init(frame: .zero)
        self.backgroundColor = color
        self.translatesAutoresizingMaskIntoConstraints = usesAutolayout
    }
    
    @available(*, unavailable) required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if didLayoutSubviews { return }
        didFinishLayoutSubviews()
        didLayoutSubviews = true
    }
    
    
    /// An empty method to be overridden for performing any setup that must run after the `UIView` superclass has laid out its subviews.
    open func didFinishLayoutSubviews() { }
}
