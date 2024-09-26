import UIKit


public extension UIImage {
    
    func rotated(by degrees: CGFloat) -> UIImage {
        
        let radians: CGFloat = degrees * .pi / 180
        
        let rotatedSize: CGSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
       
        UIGraphicsBeginImageContext(rotatedSize)
        
        guard let context: CGContext = UIGraphicsGetCurrentContext() else { return self }
        
        let originX: CGFloat = rotatedSize.width / 2
        let originY: CGFloat = rotatedSize.height / 2
        let origin = CGPoint(x: originX, y: originY)
        
        context.translateBy(x: origin.x, y: origin.y)
        context.rotate(by: radians)
        draw(
            in: CGRect(x: -origin.y, y: -origin.x,
                       width: size.width,
                       height: size.height)
        )
        
        let rotatedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return rotatedImage ?? self
    }
}
