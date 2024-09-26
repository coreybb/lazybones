import UIKit

open class LazyViewController: UIViewController {

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable) required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
