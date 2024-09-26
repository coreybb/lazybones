import UIKit


/// A protocol for creating custom font enums that provide easy access to UIFonts.
///
/// Conform to this protocol to create an enum that represents your custom fonts.
/// The raw value of each enum case should be the suffix of the font name (e.g., "-Regular", "-Bold").
public protocol LazyFontAsset: CaseIterable, RawRepresentable<String> {
    
    /// The base name of the font family.
    ///
    /// This should be the common prefix for all fonts in the family.
    /// For example, if your fonts are named "MyFont-Regular", "MyFont-Bold", etc.,
    /// the base name would be "MyFont".
    var baseName: String { get }
    
    /// The full name of the font asset.
    ///
    /// This is typically a combination of `baseName` and the enum case's raw value.
    /// The default implementation concatenates these values.
    var assetName: String { get }
    
    /// Creates a `UIFont` with the specified size.
    ///
    /// - Parameter size: The desired size of the font.
    /// - Returns: A `UIFont` instance of the custom font at the specified size.
    ///            If the font is not found, it returns a system font in release builds
    ///            or triggers a fatal error in debug builds.
    func font(size: CGFloat) -> UIFont
}



//  MARK: - Default Implementation
public extension LazyFontAsset {
    
    /// Default implementation to create a `UIFont` instance.
    ///
    /// This method attempts to create a `UIFont` with the `assetName` and specified size.
    /// If the font is not found, it falls back to a default font handling mechanism.
    func font(size: CGFloat) -> UIFont {
        UIFont(name: assetName, size: size) ?? defaultFont(badName: assetName, size: size)
    }
    
    /// Default implementation to generate the full asset name.
    ///
    /// This computed property combines the `baseName` with the enum case's raw value.
    var assetName: String {
        baseName + rawValue
    }
}



//  MARK: - Private API
extension LazyFontAsset {
    
    /// Handles cases where the specified font is not found.
    ///
    /// In debug builds, this triggers a fatal error to catch missing fonts early.
    /// In release builds, it falls back to the system font at the specified size.
    ///
    /// - Parameters:
    ///   - badName: The name of the font that wasn't found.
    ///   - size: The requested font size.
    /// - Returns: A system font in release builds.
    private func defaultFont(badName: String, size: CGFloat) -> UIFont {
        #if DEBUG
        fatalError("No such font named \(badName).")
        #else
        return UIFont.systemFont(ofSize: size)
        #endif
    }
}

