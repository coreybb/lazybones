import UIKit


public class GradientLayer: CAGradientLayer {
    
    
    //  MARK: - Public Properties
    public let direction: GradientDirection
    

    //  MARK: - Init
    public init(
        colors: [UIColor],
        direction: GradientDirection = .leftToRight
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
