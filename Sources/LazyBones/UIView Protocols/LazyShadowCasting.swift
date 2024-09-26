import UIKit


public protocol LazyShadowCasting: UIView {
    func addDropShadow(
        withOffset offset: CGFloat,
        opacity: CGFloat,
        radius: CGFloat
    )
}


//  MARK: - Default Implementation
public extension LazyShadowCasting {
    func addDropShadow(
        withOffset offset: CGFloat = 2.5,
        opacity: CGFloat = 0.3,
        radius: CGFloat = 16
    ) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: offset)
        layer.shadowRadius = 16
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
