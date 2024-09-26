import UIKit


open class LazyHStackView: LazyStackView {

    init(
        views: [UIView]? = nil,
        spacing: CGFloat = 0,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .fill,
        contentMode: UIStackView.ContentMode = .left
    ) {
        super.init(
            views: views,
            axis: .horizontal,
            spacing: spacing,
            distribution: distribution,
            alignment: alignment,
            contentMode: contentMode
        )
    }
    
    required public init(coder: NSCoder) {
        fatalError()
    }
}
