/// A protocol for defining asset folders.
public protocol AssetFolder {
    /// The name of the folder.
    ///
    /// This should correspond to the folder name in your asset catalog.
    /// Return an empty string if the assets are in the root of the catalog.
    var folderName: String { get }
}

/// Represents the absence of a folder in the asset catalog.
public enum NoFolder: AssetFolder {
    
    case root
    
    public var folderName: String { "" }
}
