import UIKit

//  MARK: - Image Assets
///
/// A protocol for creating enums that provide easy access to image assets.
///
/// Conform to this protocol to create an enum that represents your image assets.
/// The raw value of each enum case should be the name of the image asset./// Usage example:
/// ```
/// enum MyImages: String, ImageAsset {
///     case logo
///     case background
///
///     typealias Folder = MyAssetFolders.images
/// }
///
/// let logoImage = MyImages.logo.image
/// ```

public protocol ImageAsset: CaseIterable, RawRepresentable<String> {
    
    /// The folder type where the image assets are located.
    ///
    /// Use this to specify a folder structure for your assets.
    /// Defaults to `NoFolder` if not specified.
    associatedtype Folder: AssetFolder = NoFolder
    
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
    
    /// The prefix representing the folder structure for the asset.
    ///
    /// This computed property should return the folder path prefix,
    /// including a trailing slash if non-empty.
    var folderPrefix: String { get }
}


//  Default Implementation
public extension ImageAsset {
    
    /// Default implementation to retrieve the `UIImage` for the asset.
    ///
    /// This computed property attempts to load the image from the asset catalog.
    /// If the image is not found, it falls back to a default image handling mechanism.
    var image: UIImage {
        UIImage(named: assetName) ?? defaultImage(badName: assetName)
    }
    
    /// Default implementation to generate the full asset name.
    ///
    /// This computed property combines the folder prefix with the enum case's raw value.
    var assetName: String {
        folderPrefix + rawValue
    }
    
    /// Default implementation to generate the folder prefix.
    ///
    /// If a folder is specified and has a non-empty name, this returns the folder name with a trailing slash.
    /// Otherwise, it returns an empty string.
    var folderPrefix: String {
        Folder.folderName.isEmpty ? "" : Folder.folderName + "/"
    }
}


//  Private API
extension ImageAsset {

    /// Handles cases where the specified image asset is not found.
    ///
    /// In debug builds, this triggers a fatal error to catch missing assets early.
    /// In release builds, it returns an empty `UIImage`.
    ///
    /// - Parameter badName: The name of the image asset that wasn't found.
    /// - Returns: An empty `UIImage` in release builds.
    private func defaultImage(badName: String) -> UIImage {
        #if DEBUG
        fatalError("No such image asset named \(badName).")
        #else
        return UIImage()
        #endif
    }
}



//  MARK: - Asset Folders
///
/// A protocol for defining asset folders.
///
/// Conform to this protocol to create an enum that represents your asset folder structure.
///
/// Usage example:
/// ```
/// enum ImageFolders: AssetFolder {
///     case images
///     case icons
///     case backgrounds
///
///     static var folderName: String {
///         switch self {
///         case .images: return "Images"
///         case .icons: return "IconAssets"
///         case .backgrounds: return "Backgrounds"
///         }
///     }
/// }
///
/// enum MyImages: String, ImageAsset {
///     case logo
///     case splash
///
///     typealias Folder = AssetFolders.images
/// }
///
/// enum MyIcons: String, ImageAsset {
///     case home
///     case settings
///
///     typealias Folder = AssetFolders.icons
/// }
///
/// // Example using NoFolder for assets in the root of the asset catalog
/// enum RootImages: String, ImageAsset {
///     case appIcon
///     case launchScreen
///
///     typealias Folder = NoFolder
/// }
///
/// let logoImage = MyImages.logo.image
/// let homeIcon = MyIcons.home.image
/// let appIcon = RootImages.appIcon.image
/// ```
public protocol AssetFolder {
    
    /// The name of the folder.
    ///
    /// This should correspond to the folder name in your asset catalog.
    /// Return an empty string if the assets are in the root of the catalog.
    static var folderName: String { get }
}

/// Represents the absence of a folder in the asset catalog.
///
/// Use this when your assets are located in the root of the asset catalog.
public enum NoFolder: AssetFolder {
    /// Returns an empty string, indicating no folder is used.
    public static var folderName: String { "" }
}
