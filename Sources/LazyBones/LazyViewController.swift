import UIKit

/// A base view controller class designed for programmatic UI development in UIKit.
/// This class simplifies the creation of view controllers without the use of Interface Builder,
/// storyboards, or XIB files.
open class LazyViewController: UIViewController {

    /// Initializes a new instance of the view controller.
    /// This initializer sets up the view controller for programmatic UI creation,
    /// bypassing the need for a NIB file or storyboard.
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Interface Builder instantiation is not supported.
    /// - Parameter coder: An unarchiver object.
    /// - Returns: This initializer always fails and triggers a fatal error.
    @available(*, unavailable, message: "Loading this view controller from a nib is unsupported in favor of programmatic UI.")
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
