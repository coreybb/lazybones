import UIKit


final class SwipableContainerCollectionView: UICollectionView {
    
    
    init(
        view: UIView,
        cellViews: [UIView],
        axis: SwipableContainerView.SwipeAxis
    ) {
        super.init(
            frame: .zero,
            collectionViewLayout: SwipableContainerCollectionLayout(
                view: view,
                axis: axis
            )
        )
        translatesAutoresizingMaskIntoConstraints = false
        decelerationRate = UIScrollView.DecelerationRate.fast
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
