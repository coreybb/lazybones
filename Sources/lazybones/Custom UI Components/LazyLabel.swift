import UIKit


public class LazyLabel: UILabel {
    
    //  MARK: - Public Properties
    public let style: any LazyContentStyle
    
    
    //  MARK: - Init
    public init <Style: LazyContentStyle> (
        style: Style,
        numberOfLines: Int = 0,
        alignment: NSTextAlignment = .left,
        text: String = ""
    ) {
        self.style = style
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.font = style.font
        self.textColor = style.textColor
        self.numberOfLines = numberOfLines
        self.textAlignment = alignment
        self.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
