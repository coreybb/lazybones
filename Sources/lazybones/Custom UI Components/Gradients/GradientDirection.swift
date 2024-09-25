import UIKit


public enum GradientDirection {
    
    case leftToRight
    case topToBottom
    case topLeftToBottomRight
    case topRightToBottomLeft
}


//  MARK: - Public API
public extension GradientDirection {

    var startPoint: CGPoint {
        CGPoint(x: startPointX, y: startPointY)
    }
    
    var endPoint: CGPoint {
        CGPoint(x: endPointX, y: endPointY)
    }
}



//  MARK: - Private API
extension GradientDirection {

    private var startPointX: CGFloat {
        
        switch self {
        case .topToBottom: return 1
        default: return 0
        }
    }
    
    private var startPointY: CGFloat {
        
        switch self {
        case .leftToRight: return 1
        case .topToBottom: return 0
        case .topLeftToBottomRight: return 0
        case .topRightToBottomLeft: return 1
        }
    }
    
    private var endPointX: CGFloat { 1 }

    private var endPointY: CGFloat {
        switch self {
        case .topRightToBottomLeft: return 0
        default: return 1
        }
    }
}
