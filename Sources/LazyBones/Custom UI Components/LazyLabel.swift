import UIKit


public class LazyLabel: UILabel {
    
    //  MARK: - Public Properties
    public let style: (any LazyContentStyle)?
    
    
    //  MARK: - Init
    public init(
        style: (any LazyContentStyle)?,
        numberOfLines: Int = 0,
        alignment: NSTextAlignment = .left,
        text: String = ""
    ) {
        self.style = style
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.font = style?.font ?? UIFont.systemFont(ofSize: 12, weight: .regular)
        self.textColor = style?.textColor ?? .darkText
        self.numberOfLines = numberOfLines
        self.textAlignment = alignment
        self.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
