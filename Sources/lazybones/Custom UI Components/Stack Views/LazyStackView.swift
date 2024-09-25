import UIKit


open class LazyStackView: UIStackView {
    
    init(
        views: [UIView]? = nil,
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat = 0,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .center,
        contentMode: UIStackView.ContentMode = .left
    ) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        views?.forEach { addArrangedSubview($0) }
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution
        self.alignment = alignment
        self.contentMode = contentMode
    }
    
    required public init(coder: NSCoder) {
        fatalError()
    }
}
