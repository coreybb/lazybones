import UIKit


protocol PulleyPassthroughScrollViewDelegate: AnyObject {
    
    func shouldTouchPassthroughScrollView(scrollView: PullUpPassthroughScrollView, point: CGPoint) -> Bool
    func viewToReceiveTouch(scrollView: PullUpPassthroughScrollView, point: CGPoint) -> UIView
}



class PullUpPassthroughScrollView: UIScrollView {
    
    weak var touchDelegate: PulleyPassthroughScrollViewDelegate?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if let touchDelegate = touchDelegate,
            touchDelegate.shouldTouchPassthroughScrollView(
                scrollView: self,
                point: point
            ) {
            return touchDelegate.viewToReceiveTouch(
                scrollView: self,
                point: point
            ).hitTest(
                touchDelegate.viewToReceiveTouch(
                    scrollView: self,
                    point: point
                ).convert(
                    point,
                    from: self
                ),
                with: event
            )
        }
        
        return super.hitTest(point, with: event)
    }
}
