import UIKit


open class LazyView: UIView {
    
    
    private var didCompleteInitialLayout = false
 
    
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
        if didCompleteInitialLayout { return }
        didLayoutSubviews()
        didCompleteInitialLayout = true
    }
    
    
    /// An empty method to be overridden for performing any setup that must run after the `UIView` superclass has laid out its subviews.
    open func didLayoutSubviews() { }
}
