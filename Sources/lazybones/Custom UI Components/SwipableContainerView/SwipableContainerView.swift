import UIKit


/// A protocol allowing its delegate to receive updates regarding the state of the `SwipableContainerView`.
public protocol SwipableViewContainerDelegate: AnyObject {
    func didShowChildView(at index: Int)
}


/// A UIView that allows users to easily swipe between  `childViews`. A `SwipableViewContainer` allows a parent controller to retain its child controllers, and therefore observe and modify their state from a centralized class.
open class SwipableContainerView: UIView {
    
    
    //  MARK: - Internal Properties
    public weak var delegate: SwipableViewContainerDelegate?
    public var axis: SwipeAxis
    public let scrollIsEnabled: Bool
    public let collectionColor: UIColor
    private let childViews: [UIView]
    
    
    //  MARK: - Private Properties
    private lazy var collectionView: SwipableContainerCollectionView = SwipableContainerCollectionView(
        view: self,
        cellViews: childViews,
        axis: axis
    )
    private lazy var didLayoutSubviews: Bool = false
    
    
    
    
    //---------------
    //  MARK: - Init
    //---------------
    public init(
        childViews: [UIView],
        axis: SwipeAxis = .horizontal,
        backgroundColor: UIColor = .clear,
        scrollIsEnabled: Bool = true
    ) {
        self.childViews = childViews
        self.scrollIsEnabled = scrollIsEnabled
        self.axis = axis
        collectionColor = backgroundColor
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    
    
    //-------------------------------
    //  MARK: - Superclass Overrides
    //-------------------------------
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if didLayoutSubviews { return }
        setupUI()
        didLayoutSubviews = true
    }
    
    
    
    //  MARK: - Public API
    public func scrollToView(at index: Int) {
        
        guard (index <= childViews.count - 1) &&
                (index >= 0) else {
            print("The SwipableFullScreenView has no child view at index \(index), and is unable to scroll!")
            return
        }
        
        collectionView.isScrollEnabled = true
        let indexPath: IndexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.isScrollEnabled = scrollIsEnabled
    }
    
    
    public enum SwipeAxis {
        case horizontal, vertical
    }
    
    
    
    //----------------------
    //  MARK: - Private API
    //----------------------
    private func setupUI() {
    
        backgroundColor = .clear
        layoutCollectionView()
        setupCollectionView()
    }
    
    
    private func layoutCollectionView() {
        
        addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    
    private func setupCollectionView() {

        collectionView.allowsSelection = false
        collectionView.isScrollEnabled = scrollIsEnabled
        collectionView.backgroundColor = collectionColor
        collectionView.register(
            SwipableViewCollectionCell.self,
            forCellWithReuseIdentifier: SwipableViewCollectionCell.reuseID
        )
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}



extension SwipableContainerView: UICollectionViewDelegate, UICollectionViewDataSource {
    

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        childViews.count
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: SwipableViewCollectionCell = collectionView
            .dequeueReusableCell(
                withReuseIdentifier: SwipableViewCollectionCell.reuseID,
                for: indexPath
            ) as! SwipableViewCollectionCell
        cell.hostedView = childViews[indexPath.item]
        return cell
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        delegate?.didShowChildView(at: indexPath.item)
    }
    
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let currentCell: SwipableViewCollectionCell = collectionView.visibleCells.first! as! SwipableViewCollectionCell
        let index: Int = childViews.enumerated().first { currentCell.hostedView == $0.element }!.offset
        delegate?.didShowChildView(at: index)
    }
}
