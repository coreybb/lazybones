import UIKit

/// A subclass of `UIImageView` that provides convenient initializers and automatically sets
/// `translatesAutoresizingMaskIntoConstraints` to `false`.
open class LazyImageView: UIImageView {
    
    // MARK: - Initializers
    
    /// Creates a LazyImageView with a UIImage and content mode.
    ///
    /// - Parameters:
    ///   - image: The image to display.
    ///   - contentMode: The content mode for the image view. Defaults to .scaleAspectFit.
    public init(
        image: UIImage,
        contentMode: ContentMode = .scaleAspectFit
    ) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.image = image
        self.contentMode = contentMode
    }
    
    /// Creates a LazyImageView with an ImageAsset and content mode.
    ///
    /// - Parameters:
    ///   - asset: The image asset to display.
    ///   - contentMode: The content mode for the image view. Defaults to .scaleAspectFit.
    public convenience init(
        asset: any ImageAsset,
        contentMode: ContentMode = .scaleAspectFit
    ) {
        self.init(image: asset.image, contentMode: contentMode)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
