import UIKit


open class LazyVStackView: LazyStackView {

    init(
        views: [UIView]? = nil,
        spacing: CGFloat = 0,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .fill,
        contentMode: UIStackView.ContentMode = .left
    ) {
        super.init(
            views: views,
            axis: .vertical,
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
