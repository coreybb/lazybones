import UIKit

/// A protocol for creating enums that provide easy access to image assets.
public protocol LazyImageAsset: CaseIterable, RawRepresentable<String> {
    /// The folder where the image assets are located.
    ///
    /// Use this to specify a folder structure for your assets.
    var folder: LazyAssetFolder { get }
    
    /// The `UIImage` instance corresponding to the enum case.
    ///
    /// This computed property loads the image from the asset catalog.
    /// If the image is not found, it returns a default image or triggers a fatal error in debug builds.
    var image: UIImage { get }
    
    /// The full name of the image asset, including any folder prefix.
    ///
    /// This computed property should return the complete path to the image asset,
    /// including the folder name (if any) and the asset name.
    var assetName: String { get }
}

// MARK: - Default Implementation
public extension LazyImageAsset {
    /// Default implementation to retrieve the `UIImage` for the asset.
    ///
    /// This computed property attempts to load the image from the asset catalog.
    /// If the image is not found, it falls back to a default image handling mechanism.
    var image: UIImage {
        UIImage(named: assetName) ?? defaultImage(badName: assetName)
    }
    
    /// Default implementation to generate the full asset name.
    ///
    /// This computed property combines the folder name with the enum case's raw value.
    var assetName: String {
        let prefix = folder.folderName
        return prefix.isEmpty ? rawValue : prefix + "/" + rawValue
    }
}

// MARK: - Private API
private extension LazyImageAsset {
    /// Handles cases where the specified image asset is not found.
    ///
    /// In debug builds, this triggers a fatal error to catch missing assets early.
    /// In release builds, it returns an empty `UIImage`.
    ///
    /// - Parameter badName: The name of the image asset that wasn't found.
    /// - Returns: An empty `UIImage` in release builds.
    func defaultImage(badName: String) -> UIImage {
        #if DEBUG
        fatalError("No such image asset named \(badName).")
        #else
        return UIImage()
        #endif
    }
}
