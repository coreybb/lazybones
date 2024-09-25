import UIKit


public extension UIControl {
    
    /// A simplified call-site for adding actions to UIControl objects like UIButton. Its default event is `.touchUpInside`.
    func addAction(for event: UIControl.Event = .touchUpInside, handler: @escaping UIActionHandler) {
        addAction(UIAction(handler: handler), for: event)
    }
}
