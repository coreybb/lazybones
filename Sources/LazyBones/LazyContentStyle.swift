import UIKit

public protocol LazyContentStyle {
    
    associatedtype CustomContentContext: LazyContentContext
    associatedtype CustomContentType: LazyContentType
    
    var context: CustomContentContext { get }
    var type: CustomContentType { get }
    
    var font: UIFont { get }
    var textColor: UIColor { get }
}



// MARK: - Default Implementation
public extension LazyContentStyle {
    var font: UIFont {
        type.fontAsset.font(size: type.size.pointSize)
    }
    
    var textColor: UIColor {
        context.textColor.color
    }
}


//  MARK: - Content Context
public protocol LazyContentContext {
    var textColor: any LazyColorAsset { get }
}



//  MARK: - Content Size
public protocol LazyContentSize {
    var pointSize: CGFloat { get }
}



//  MARK: - Content Type
public protocol LazyContentType {
    var fontAsset: any LazyFontAsset { get }
    var size: LazyContentSize { get }
}


/// Usage Example:
///
/// ```
/// // Define custom font assets
/// enum CustomFont: String, FontAsset {
///     case regular = "-Regular"
///     case bold = "-Bold"
///
///     var baseName: String { "CustomFont" }
/// }
///
/// // Define custom color assets
/// enum TextColor: String, ColorAsset {
///     case label = "LabelColor"
///     case secondaryLabel = "SecondaryLabelColor"
///
///     var folder: AssetFolder { NoFolder.root }
/// }
///
/// // Define content sizes
/// enum TextSize: ContentSize {
///     case small, medium, large
///
///     var pointSize: CGFloat {
///         switch self {
///         case .small: return 12
///         case .medium: return 16
///         case .large: return 24
///         }
///     }
/// }
///
/// // Define content context
/// enum TextImportance: ContentContext {
///     case primary, secondary
///
///     var textColor: any ColorAsset {
///         switch self {
///         case .primary: return TextColor.label
///         case .secondary: return TextColor.secondaryLabel
///         }
///     }
/// }
///
/// // Define content types
/// enum TextStyle: ContentType {
///     case title, body
///
///     var fontAsset: any FontAsset {
///         switch self {
///         case .title: return CustomFont.bold
///         case .body: return CustomFont.regular
///         }
///     }
///
///     var size: ContentSize {
///         switch self {
///         case .title: return TextSize.large
///         case .body: return TextSize.medium
///         }
///     }
/// }
///
/// // Implement LazyContentStyle
/// struct CustomTextStyle: LazyContentStyle {
///     let context: TextImportance
///     let type: TextStyle
/// }
///
/// // Usage in a view controller
/// class ViewController: UIViewController {
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         let titleStyle = CustomTextStyle(context: .primary, type: .title)
///         let bodyStyle = CustomTextStyle(context: .secondary, type: .body)
///
///         let titleLabel = LazyLabel(style: titleStyle, text: "Welcome")
///         let bodyLabel = LazyLabel(style: bodyStyle, text: "This is a custom styled label.")
///
///         // Add labels to view hierarchy and set up constraints
///         view.addSubview(titleLabel)
///         view.addSubview(bodyLabel)
///
///         NSLayoutConstraint.activate([
///             titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
///             titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
///
///             bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
///             bodyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
///         ])
///     }
/// }
/// ```
