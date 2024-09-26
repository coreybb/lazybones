import UIKit


open class LazyTextField: UITextField {
    
    
    //---------------
    //  MARK: - Init
    //---------------
    public init(
        style: (any LazyContentStyle)? = nil,
        keyboardType: UIKeyboardType = .default,
        placeholder: String = "",
        alignment: NSTextAlignment = .left
    ) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        font = style?.font
        textColor = style?.textColor
        textAlignment = alignment
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
}


//  MARK: - Private API
extension LazyTextField {
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        adjustsFontSizeToFitWidth = true
    }
}

