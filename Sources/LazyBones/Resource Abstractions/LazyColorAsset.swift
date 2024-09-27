import UIKit

public protocol LazyColorAsset: CaseIterable, RawRepresentable<String> {
    /// The folder where the color assets are located.
    ///
    /// Use this to specify a folder structure for your assets.
    /// Defaults to `NoFolder` if not specified.
    var folder: LazyAssetFolder { get }
    
    /// The full name of the color asset, including any folder prefix.
    ///
    /// This computed property should return the complete path to the color asset,
    /// including the folder name (if any) and the asset name.
    var colorName: String { get }
    
    /// Returns the specified color.
    var color: UIColor { get }
    
    /// Returns the specified color as a `CGColor`.
    var cgColor: CGColor { get }
}

// MARK: - Default Implementation
public extension LazyColorAsset {
    /// Default implementation to retrieve `UIColor`.
    var color: UIColor {
        UIColor(named: colorName) ?? defaultColor
    }
    
    /// Default implementation to retrieve `CGColor`.
    var cgColor: CGColor {
        color.cgColor
    }

    /// Default implementation to generate the full asset name.
    ///
    /// This computed property combines the folder name with the enum case's raw value.
    var colorName: String {
        let prefix = folder.folderName
        return prefix.isEmpty ? rawValue : prefix + "/" + rawValue
    }
}

// MARK: - Private API
private extension LazyColorAsset {
    /// Default color to return if the specified color asset is not found.
    var defaultColor: UIColor {
        #if DEBUG
        fatalError("No such color named \(colorName).")
        #else
        return UIColor.lightGray
        #endif
    }
}
