import UIKit


public class LazyGradientLayer: CAGradientLayer {
    
    
    //  MARK: - Public Properties
    public let direction: LazyGradientDirection
    

    //  MARK: - Init
    public init(
        colors: [UIColor],
        direction: LazyGradientDirection = .leftToRight
    ) {
        self.direction = direction
        super.init()
        self.colors = colors.map { $0.cgColor }
        startPoint = direction.startPoint
        endPoint = direction.endPoint
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
