import UIKit


open class SwipableContainerCollectionLayout: CenteredCollectionViewFlowLayout {
    
    public init(view: UIView, axis: SwipableContainerView.SwipeAxis) {
        super.init()
        
        scrollDirection = axis == .horizontal ? .horizontal : .vertical
        minimumInteritemSpacing = 5

        let topPadding: CGFloat = 0
        sectionInset = UIEdgeInsets(top: topPadding, left: 0, bottom: 0, right: 0)
        let size: CGSize = CGSize(width: view.frame.width, height: view.frame.height)
        itemSize = size
    }

    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
