import UIKit

/// A custom UIView subclass designed for programmatic UI development in UIKit.
/// This class provides a convenient base for creating views with custom initial setup
/// and layout behavior.
open class LazyView: UIView {
    
    /// Tracks whether the initial layout pass has been completed.
    private var didCompleteInitialLayout = false
 
    
    /// Initializes a new instance of the view.
    /// - Parameters:
    ///   - color: The background color for the view. Defaults to nil (transparent).
    ///   - usesAutolayout: A boolean indicating whether the view should use Auto Layout.
    ///     If true, `translatesAutoresizingMaskIntoConstraints` is set to false. Defaults to false.
    public init(
        color: UIColor? = nil,
        usesAutolayout: Bool = false
    ) {
        super.init(frame: .zero)
        self.backgroundColor = color
        self.translatesAutoresizingMaskIntoConstraints = !usesAutolayout
    }
    
    
    /// Interface Builder instantiation is not supported.
    /// - Parameter coder: An unarchiver object.
    /// - Returns: This initializer always fails and triggers a fatal error.
    @available(*, unavailable, message: "Loading this view from a nib is unsupported in favor of programmatic UI.")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if didCompleteInitialLayout { return }
        didLayoutSubviews()
        didCompleteInitialLayout = true
    }
    
    
    /// An empty method to be overridden for performing any setup that must run
    /// after the `UIView` superclass has laid out its subviews.
    /// This method is called only once, during the first layout pass.
    open func didLayoutSubviews() { }
}
