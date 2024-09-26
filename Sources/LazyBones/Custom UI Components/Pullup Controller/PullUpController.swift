import UIKit

@MainActor
open class PullUpController: UIViewController, @preconcurrency PulleyDrawerViewControllerDelegate {
    
    
    //-----------------------------
    //  MARK: - Private Properties
    //-----------------------------
    private let kPulleyDefaultCollapsedHeight: CGFloat = 68.0
    private let kPulleyDefaultPartialRevealHeight: CGFloat = 264.0
    private let primaryContentContainer: UIView = UIView()
    private let drawerContentContainer: UIView = UIView()
    private let drawerShadowView: UIView = UIView()
    private let drawerScrollView: PullUpPassthroughScrollView = PullUpPassthroughScrollView()
    private let backgroundDimmingView: UIView = UIView()
    private var dimmingViewTapRecognizer: UITapGestureRecognizer?
    private var lastDragTargetContentOffset: CGPoint = CGPoint.zero
    private var isAnimatingDrawerPosition: Bool = false
    private var isChangingDrawerPosition: Bool = false
    
    /// The height of the open position for the drawer
    public var heightOfOpenDrawer: CGFloat {
        
        let safeAreaTopInset = pulleySafeAreaInsets.top
        let safeAreaBottomInset = pulleySafeAreaInsets.bottom

        var height = view.bounds.height - safeAreaTopInset
        
        if currentDisplayMode == .panel {
            height -= (panelInsets.top + bounceOverflowMargin)
            height -= (panelInsets.bottom + safeAreaBottomInset)
        } else if currentDisplayMode == .drawer {
            height -= drawerTopInset
        }
        
        return height
    }

    
    //----------------------------
    //  MARK: - Public Properties
    //----------------------------
    public let bounceOverflowMargin: CGFloat = 20.0

    /// The current content view controller (shown behind the drawer).
    public private(set) var primaryContentViewController: UIViewController! {
        willSet {
            guard let controller = primaryContentViewController else { return }
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }
        
        didSet {
            guard let controller = primaryContentViewController else { return }
            addChild(controller)
            primaryContentContainer.addSubview(controller.view)
            
            controller.view.fillSuperview()
            controller.didMove(toParent: self)

            if isViewLoaded {
                view.setNeedsLayout()
                setNeedsSupportedDrawerPositionsUpdate()
            }
        }
    }
    
    /// The current drawer view controller (shown in the drawer).
    public private(set) var drawerContentViewController: UIViewController! {
        willSet {
            guard let controller = drawerContentViewController else { return }
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }

        didSet {

            guard let controller = drawerContentViewController else { return }

            addChild(controller)
            drawerContentContainer.addSubview(controller.view)
            controller.view.fillSuperview()
            controller.didMove(toParent: self)

            if isViewLoaded {
                view.setNeedsLayout()
                setNeedsSupportedDrawerPositionsUpdate()
            }
        }
    }
    
    /// Get the current bottom safe area for Pulley. This is a convenience accessor. Most delegate methods where you'd need it will deliver it as a parameter.
    public var bottomSafeSpace: CGFloat {
        get {
            return pulleySafeAreaInsets.bottom
        }
    }
    
    /// The content view controller and drawer controller can receive delegate events already. This lets another object observe the changes, if needed.
    public weak var delegate: PulleyDelegate?
    
    /// The current position of the drawer.
    public private(set) var drawerPosition: PulleyPosition = .collapsed {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    // The visible height of the drawer. Useful for adjusting the display of content in the main content view.
    public var visibleDrawerHeight: CGFloat {
        if drawerPosition == .closed {
            return 0.0
        } else {
            return drawerScrollView.bounds.height
        }
    }

    // Returns default blur style depends on iOS version.
    private static var defaultBlurEffect: UIBlurEffect.Style = .systemUltraThinMaterial

    /// The background visual effect layer for the drawer. By default this is the extraLight effect. You can change this if you want, or assign nil to remove it.
    public var drawerBackgroundVisualEffectView: UIVisualEffectView? = UIVisualEffectView(effect: UIBlurEffect(style: defaultBlurEffect)) {
        willSet {
            drawerBackgroundVisualEffectView?.removeFromSuperview()
        }
        didSet {
            
            if let drawerBackgroundVisualEffectView = drawerBackgroundVisualEffectView,
                isViewLoaded {
                drawerScrollView.insertSubview(drawerBackgroundVisualEffectView, aboveSubview: drawerShadowView)
                drawerBackgroundVisualEffectView.clipsToBounds = true
                drawerBackgroundVisualEffectView.layer.cornerRadius = drawerCornerRadius
                view.setNeedsLayout()
            }
        }
    }
    
    /// The inset from the top safe area when the drawer is fully open. This property is only for the 'drawer' displayMode. Use panelInsets to control the top/bottom/left/right insets for the panel.
    public var drawerTopInset: CGFloat = 20.0 {
        didSet {
            if oldValue != drawerTopInset,
                isViewLoaded {
                view.setNeedsLayout()
            }
        }
    }
    
    /// This replaces the previous panelInsetLeft and panelInsetTop properties. Depending on what corner placement is being used, different values from this struct will apply. For example, 'topLeft' corner placement will utilize the .top, .left, and .bottom inset properties and it will ignore the .right property (use panelWidth property to specify width)
    public var panelInsets: UIEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0) {
        didSet {
            if oldValue != panelInsets,
                isViewLoaded {
                view.setNeedsLayout()
            }
        }
    }
    
    /// The width of the panel in panel displayMode
    public var panelWidth: CGFloat = 325.0 {
        didSet {
            if oldValue != panelWidth, isViewLoaded {
                view.setNeedsLayout()
            }
        }
    }
    
    /// Depending on what corner placement is being used, different values from this struct will apply. For example, 'bottomRight' corner placement will utilize the .top, .right, and .bottom inset properties and it will ignore the .left property (use compactWidth property to specify width)
    public var compactInsets: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 10.0, right: 8.0) {
        didSet {
            if oldValue != compactInsets,
                isViewLoaded {
                view.setNeedsLayout()
            }
        }
    }

    /// The width of the drawer in compact displayMode
    public var compactWidth: CGFloat = 292.0 {
        didSet {
            if oldValue != compactWidth,
                isViewLoaded {
                view.setNeedsLayout()
            }
        }
    }
    
    /// The corner radius for the drawer.
    /// Note: This property is ignored if your drawerContentViewController's view.layer.mask has a custom mask applied using a CAShapeLayer.
    /// Note: Custom CAShapeLayer as your drawerContentViewController's view.layer mask will override Pulley's internal corner rounding and use that mask as the drawer mask.
    public var drawerCornerRadius: CGFloat = 50.0 {
        didSet {
            if isViewLoaded {
                if oldValue != drawerCornerRadius {
                    view.setNeedsLayout()
                }
                drawerBackgroundVisualEffectView?.layer.cornerRadius = drawerCornerRadius
            }
        }
    }
    
    /// The opacity of the drawer shadow.
    public var shadowOpacity: Float = 0.1 {
        didSet {
            if isViewLoaded {
                drawerShadowView.layer.shadowOpacity = shadowOpacity
                if oldValue != shadowOpacity {
                    view.setNeedsLayout()
                }
            }
        }
    }
    
    /// The radius of the drawer shadow.
    public var shadowRadius: CGFloat = 8.0 {
        didSet {
            if isViewLoaded {
                drawerShadowView.layer.shadowRadius = shadowRadius
                if oldValue != shadowRadius {
                    view.setNeedsLayout()
                }
            }

        }
    }
    
    /// The offset of the drawer shadow.
    public var shadowOffset = CGSize(width: 0.0, height: -3.0) {
        didSet {
            if isViewLoaded {
                drawerShadowView.layer.shadowOffset = shadowOffset
                if oldValue != shadowOffset {
                    view.setNeedsLayout()
                }
            }
        }
    }

    /// The opaque color of the background dimming view.
    public var backgroundDimmingColor: UIColor = UIColor.black {
        didSet {
            if isViewLoaded {
                backgroundDimmingView.backgroundColor = backgroundDimmingColor
            }
        }
    }
    
    /// The maximum amount of opacity when dimming.
    public var backgroundDimmingOpacity: CGFloat = 0.5 {
        didSet {
            if isViewLoaded {
                scrollViewDidScroll(drawerScrollView)
            }
        }
    }
    
    /// The drawer scrollview's delaysContentTouches setting
    public var delaysContentTouches: Bool = true {
        didSet {
            if isViewLoaded {
                drawerScrollView.delaysContentTouches = delaysContentTouches
            }
        }
    }
    
    /// The drawer scrollview's canCancelContentTouches setting
    public var canCancelContentTouches: Bool = true {
        didSet {
            if isViewLoaded {
                drawerScrollView.canCancelContentTouches = canCancelContentTouches
            }
        }
    }
    
    /// The starting position for the drawer when it first loads
    public var initialDrawerPosition: PulleyPosition = .collapsed
    
    /// The display mode for Pulley. Default is 'drawer', which preserves the previous behavior of Pulley. If you want it to adapt automatically, choose 'automatic'. The current display mode is available by using the 'currentDisplayMode' property.
    public var displayMode: PulleyDisplayMode = .drawer {
        didSet {
            if isViewLoaded {
                view.setNeedsLayout()
            }
        }
    }
    
    /// The Y positioning for Pulley. This property is only oberserved when `displayMode` is set to `.automatic` or `.pannel`. Default value is `.topLeft`.
    public var panelCornerPlacement: PulleyPanelCornerPlacement = .topLeft {
        didSet {
            if isViewLoaded {
                view.setNeedsLayout()
            }
        }
    }
    ////////////////////////
    
    /// The Y positioning for Pulley. This property is only oberserved when `displayMode` is set to `.automatic` or `.compact`. Default value is `.bottomLeft`.
    public var compactCornerPlacement: PulleyCompactCornerPlacement = .bottomLeft {
        didSet {
            if isViewLoaded {
                view.setNeedsLayout()
            }
        }
    }

    /// Whether the drawer's position can be changed by the user. If set to `false`, the only way to move the drawer is programmatically. Defaults to `true`.
    public var allowsUserDrawerPositionChange: Bool = true {
        didSet {
            enforceCanScrollDrawer()
        }
    }
    
    /// The animation duration for setting the drawer position
    public var animationDuration: TimeInterval = 0.3
    
    /// The animation delay for setting the drawer position
    public var animationDelay: TimeInterval = 0.0
    
    /// The spring damping for setting the drawer position
    public var animationSpringDamping: CGFloat = 0.75
    
    /// The spring's initial velocity for setting the drawer position
    public var animationSpringInitialVelocity: CGFloat = 0.0
    
    /// This setting allows you to enable/disable Pulley automatically insetting the drawer on the left/right when in 'bottomDrawer' display mode in a horizontal orientation on a device with a 'notch' or other left/right obscurement.
    public var adjustDrawerHorizontalInsetToSafeArea: Bool = true {
        didSet {
            if isViewLoaded {
                view.setNeedsLayout()
            }
        }
    }
    
    /// The animation options for setting the drawer position
    public var animationOptions: UIView.AnimationOptions = [.curveEaseInOut]
    
    /// The drawer snap mode
    public var snapMode: PulleySnapMode = .nearestPositionUnlessExceeded(threshold: 20.0)

    public var feedbackGenerator: UIFeedbackGenerator?
    
    /// Access to the safe areas that Pulley is using for layout (provides compatibility for iOS < 11)
    open var pulleySafeAreaInsets: UIEdgeInsets {
        UIEdgeInsets(
            top: view.safeAreaInsets.top,
            left: view.safeAreaInsets.left,
            bottom: view.safeAreaInsets.bottom,
            right: view.safeAreaInsets.right
        )
    }
    
    /// Get the current drawer distance. This value is equivalent in nature to the one delivered by PulleyDelegate's `drawerChangedDistanceFromBottom` callback.
    public var drawerDistanceFromBottom: (distance: CGFloat, bottomSafeArea: CGFloat) {
        
        if isViewLoaded {
            let lowestStop = getStopList().min() ?? 0.0
            return (distance: drawerScrollView.contentOffset.y + lowestStop,
                    bottomSafeArea: pulleySafeAreaInsets.bottom)
        }
        
        return (distance: 0.0, bottomSafeArea: 0.0)
    }
    
    // The position the pulley should animate to when the background is tapped. Default is collapsed.
    public var positionWhenDimmingBackgroundIsTapped: PulleyPosition = .collapsed
    
    /// Get all gesture recognizers in the drawer scrollview
    public var drawerGestureRecognizers: [UIGestureRecognizer] {
        get {
            return drawerScrollView.gestureRecognizers ?? [UIGestureRecognizer]()
        }
    }
    
    /// Get the drawer scrollview's pan gesture recognizer
    public var drawerPanGestureRecognizer: UIPanGestureRecognizer {
        get {
            return drawerScrollView.panGestureRecognizer
        }
    }
    
    /// The drawer positions supported by the drawer
    private var supportedPositions: [PulleyPosition] = PulleyPosition.all {
        didSet {
            
            guard isViewLoaded else { return }
            
            guard supportedPositions.count > 0 else {
                supportedPositions = (currentDisplayMode == .compact) ? PulleyPosition.compact : PulleyPosition.all
                return
            }
            
            if oldValue != supportedPositions {
                view.setNeedsLayout()
            }
            
            if supportedPositions.contains(drawerPosition) {
                setDrawerPosition(position: drawerPosition, animated: false)
            } else if currentDisplayMode == .compact
                       && drawerPosition == .partiallyRevealed
                       && supportedPositions.contains(.open) {
                setDrawerPosition(position: .open, animated: false)
            } else {
                let lowestDrawerState: PulleyPosition = supportedPositions
                    .filter( { $0 != .closed })
                    .min { (pos1, pos2) -> Bool in
                        return pos1.rawValue < pos2.rawValue
                    } ?? .collapsed
                
                setDrawerPosition(position: lowestDrawerState, animated: false)
            }
            
            enforceCanScrollDrawer()
        }
    }
    
    /// The currently rendered display mode for Pulley. This will match displayMode unless you have it set to 'automatic'. This will provide the 'actual' display mode (never automatic).
    public private(set) var currentDisplayMode: PulleyDisplayMode = .automatic {
        didSet {
            
            if oldValue != currentDisplayMode {
               
                if isViewLoaded {
                    view.setNeedsLayout()
                    setNeedsSupportedDrawerPositionsUpdate()
                }
                
                delegate?.drawerDisplayModeDidChange?(drawer: self)
                (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.drawerDisplayModeDidChange?(drawer: self)
                (primaryContentContainer as? PulleyPrimaryContentControllerDelegate)?.drawerDisplayModeDidChange?(drawer: self)
            }
        }
    }
        
    
    
    //---------------
    //  MARK: - Init
    //---------------
    /**
     - Parameter contentViewController: The content view controller. This view controller is shown behind the drawer.
     - Parameter drawerViewController:  The view controller to display inside the drawer.
     
     - Note: The drawer VC is 20pts too tall in order to have some extra space for the bounce animation. Make sure your constraints / content layout take this into account.
     
     - Returns: A newly created Pulley drawer.
     */
    public init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)

        ({
            primaryContentViewController = contentViewController
            drawerContentViewController = drawerViewController
        })()
        
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    //-------------------------------
    //  MARK: - Superclass Overrides
    //-------------------------------
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setNeedsSupportedDrawerPositionsUpdate()
    }
    
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

       handleViewDidLayoutSubviews()
    }
    
    
    private func handleViewDidLayoutSubviews() {
        
        if let primary = primaryContentViewController {
            if primary.view.superview != nil,
               primary.view.superview != primaryContentContainer {
                primaryContentContainer.addSubview(primary.view)
                primaryContentContainer.sendSubviewToBack(primary.view)
                primary.view.fillSuperview()
            }
        }
        
        if let drawer = drawerContentViewController {
            if drawer.view.superview != nil,
               drawer.view.superview != drawerContentContainer {
                drawerContentContainer.addSubview(drawer.view)
                drawerContentContainer.sendSubviewToBack(drawer.view)
                drawer.view.fillSuperview()
            }
        }

        let topInset = pulleySafeAreaInsets.top
        let bottomInset = pulleySafeAreaInsets.bottom
        let leftPadding = pulleySafeAreaInsets.left
        let rightInset = pulleySafeAreaInsets.right
        
        var automaticDisplayMode: PulleyDisplayMode = .drawer
        let magicNumber: CGFloat = 600
        
        if view.bounds.width >= magicNumber {
            switch traitCollection.horizontalSizeClass {
            case .compact: automaticDisplayMode = .compact
            default: automaticDisplayMode = .panel
            }
        }
        
        let displayModeForCurrentLayout: PulleyDisplayMode = displayMode != .automatic ? displayMode : automaticDisplayMode
        
        currentDisplayMode = displayModeForCurrentLayout
        
        if displayModeForCurrentLayout == .drawer {
            // Bottom inset for safe area / bottomLayoutGuide

            drawerScrollView.contentInsetAdjustmentBehavior = .scrollableAxes


            let lowestStop = getStopList().min() ?? 0
            
            let adjustedLeftSafeArea = adjustDrawerHorizontalInsetToSafeArea ? leftPadding : 0.0
            let adjustedRightSafeArea = adjustDrawerHorizontalInsetToSafeArea ? rightInset : 0.0
            
            if supportedPositions.contains(.open) {
                // Layout scrollview
                drawerScrollView.frame = CGRect(
                    x: adjustedLeftSafeArea,
                    y: drawerTopInset + topInset,
                    width: view.bounds.width - adjustedLeftSafeArea - adjustedRightSafeArea,
                    height: heightOfOpenDrawer
                )
            } else {
                // Layout scrollview
                let adjustedTopInset: CGFloat = getStopList().max() ?? 0.0
                drawerScrollView.frame = CGRect(
                    x: adjustedLeftSafeArea,
                    y: view.bounds.height - adjustedTopInset,
                    width: view.bounds.width - adjustedLeftSafeArea - adjustedRightSafeArea,
                    height: adjustedTopInset
                )
            }
            
            drawerScrollView.addSubview(drawerShadowView)
            
            if let drawerBackgroundVisualEffectView = drawerBackgroundVisualEffectView {
                drawerScrollView.addSubview(drawerBackgroundVisualEffectView)
                drawerBackgroundVisualEffectView.layer.cornerRadius = drawerCornerRadius
            }
            
            drawerScrollView.addSubview(drawerContentContainer)
            
            drawerContentContainer.frame = CGRect(
                x: 0,
                y: drawerScrollView.bounds.height - lowestStop,
                width: drawerScrollView.bounds.width,
                height: drawerScrollView.bounds.height + bounceOverflowMargin
            )
            drawerBackgroundVisualEffectView?.frame = drawerContentContainer.frame
            drawerShadowView.frame = drawerContentContainer.frame
            drawerScrollView.contentSize = CGSize(
                width: drawerScrollView.bounds.width,
                height: (drawerScrollView.bounds.height - lowestStop) + drawerScrollView.bounds.height - bottomInset + (bounceOverflowMargin - 5.0)
            )
            
            // Update rounding mask and shadows
            let borderPath = drawerMaskingPath(
                byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight]
            ).cgPath

            let cardMaskLayer = CAShapeLayer()
            cardMaskLayer.path = borderPath
            cardMaskLayer.frame = drawerContentContainer.bounds
            cardMaskLayer.fillColor = UIColor.white.cgColor
            cardMaskLayer.backgroundColor = UIColor.clear.cgColor
            drawerContentContainer.layer.mask = cardMaskLayer
            drawerShadowView.layer.shadowPath = borderPath
            
            backgroundDimmingView.frame = CGRect(
                x: 0.0,
                y: 0.0,
                width: view.bounds.width,
                height: view.bounds.height + drawerScrollView.contentSize.height
            )
            
            drawerScrollView.transform = CGAffineTransform.identity
            
            backgroundDimmingView.isHidden = false
        } else {
            // Bottom inset for safe area / bottomLayoutGuide

            drawerScrollView.contentInsetAdjustmentBehavior = .scrollableAxes
            
            // Layout container
            var collapsedHeight:CGFloat = kPulleyDefaultCollapsedHeight
            var partialRevealHeight:CGFloat = kPulleyDefaultPartialRevealHeight
            
            if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate {
                collapsedHeight = drawerVCCompliant.collapsedDrawerHeight?(bottomSafeArea: bottomInset) ?? kPulleyDefaultCollapsedHeight
                partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight?(bottomSafeArea: bottomInset) ?? kPulleyDefaultPartialRevealHeight
            }
            
            var lowestStop: CGFloat = 0
            var xOrigin: CGFloat = 0
            var yOrigin: CGFloat = 0
            let width = displayModeForCurrentLayout == .compact ? compactWidth : panelWidth
            
            if (displayModeForCurrentLayout == .compact) {
                lowestStop = [(self.view.bounds.size.height - compactInsets.bottom - topInset), collapsedHeight, partialRevealHeight].min() ?? 0
                xOrigin = (compactCornerPlacement == .bottomLeft) ? (leftPadding + compactInsets.left) : (view.bounds.maxX - (rightInset + compactInsets.right) - compactWidth)
                
                yOrigin = (compactInsets.top + topInset)
            } else {
                lowestStop = [(self.view.bounds.size.height - panelInsets.bottom - topInset), collapsedHeight, partialRevealHeight].min() ?? 0
                xOrigin = (panelCornerPlacement == .bottomLeft || panelCornerPlacement == .topLeft) ? (leftPadding + panelInsets.left) : (view.bounds.maxX - (rightInset + panelInsets.right) - panelWidth)
                
                yOrigin = (panelCornerPlacement == .bottomLeft || panelCornerPlacement == .bottomRight) ? (panelInsets.top + topInset) : (panelInsets.top + topInset + bounceOverflowMargin)
                
            }
            
            if supportedPositions.contains(.open) {
                // Layout scrollview
                drawerScrollView.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: heightOfOpenDrawer)
            } else {
                // Layout scrollview
                let adjustedTopInset: CGFloat = supportedPositions.contains(.partiallyRevealed) ? partialRevealHeight : collapsedHeight
                drawerScrollView.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: adjustedTopInset)
            }

            syncDrawerContentViewSizeToMatchScrollPositionForSideDisplayMode()
            
            drawerScrollView.contentSize = CGSize(width: drawerScrollView.bounds.width, height: self.view.bounds.height + (self.view.bounds.height - lowestStop))
            
            if displayModeForCurrentLayout == .compact {
                switch compactCornerPlacement {
                case .bottomLeft, .bottomRight:
                    drawerScrollView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            } else {
                switch panelCornerPlacement {
                case .topLeft, .topRight:
                    drawerScrollView.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
                case .bottomLeft, .bottomRight:
                    drawerScrollView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }

            backgroundDimmingView.isHidden = true
        }
        
        drawerContentContainer.transform = drawerScrollView.transform
        drawerShadowView.transform = drawerScrollView.transform
        drawerBackgroundVisualEffectView?.transform = drawerScrollView.transform
        
        let lowestStop = getStopList().min() ?? 0
        
        delegate?.drawerChangedDistanceFromBottom?(drawer: self, distance: drawerScrollView.contentOffset.y + lowestStop, bottomSafeArea: pulleySafeAreaInsets.bottom)
        (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.drawerChangedDistanceFromBottom?(drawer: self, distance: drawerScrollView.contentOffset.y + lowestStop, bottomSafeArea: pulleySafeAreaInsets.bottom)
        (primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.drawerChangedDistanceFromBottom?(drawer: self, distance: drawerScrollView.contentOffset.y + lowestStop, bottomSafeArea: pulleySafeAreaInsets.bottom)
        
        maskDrawerVisualEffectView()
        maskBackgroundDimmingView()
        
        // Do not need to set the the drawer position in layoutSubview if the position of the drawer is changing
        // and the view is being layed out. If the drawer position is changing and the view is layed out (i.e.
        // a value or constraints are bing updated) the drawer is always set to the last position,
        // and no longer scrolls properly.
        if isChangingDrawerPosition == false {
            setDrawerPosition(position: drawerPosition, animated: false)
        }
    }
    
    
    
    //----------------------
    //  MARK: - Private API
    //----------------------
    private func setup() {
        
        primaryContentContainer.backgroundColor = UIColor.white
        definesPresentationContext = true
        setupDrawerScrollView()
        setupDrawerShadowView()
        drawerContentContainer.backgroundColor = UIColor.clear
        setupBackgroundDimmingView()
        
        drawerBackgroundVisualEffectView?.clipsToBounds = true
        
        dimmingViewTapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(PullUpController.dimmingViewTapRecognizerAction(gestureRecognizer:))
        )
        backgroundDimmingView.addGestureRecognizer(dimmingViewTapRecognizer!)
        
        drawerScrollView.addSubview(drawerShadowView)
        
        if let drawerBackgroundVisualEffectView = drawerBackgroundVisualEffectView {
            drawerScrollView.addSubview(drawerBackgroundVisualEffectView)
            drawerBackgroundVisualEffectView.layer.cornerRadius = drawerCornerRadius
        }
        
        drawerScrollView.addSubview(drawerContentContainer)
        
        primaryContentContainer.backgroundColor = UIColor.white
        
        view.backgroundColor = UIColor.white
        view.addSubview(primaryContentContainer)
        view.addSubview(backgroundDimmingView)
        view.addSubview(drawerScrollView)
        primaryContentContainer.fillSuperview()
        
        performViewDidLoadSetupThatsTotallyDifferentFromLoadView()
    }
    
    
    private func setupDrawerScrollView() {
        
        drawerScrollView.bounces = false
        drawerScrollView.delegate = self
        drawerScrollView.clipsToBounds = false
        drawerScrollView.showsVerticalScrollIndicator = false
        drawerScrollView.showsHorizontalScrollIndicator = false
        
        drawerScrollView.delaysContentTouches = delaysContentTouches
        drawerScrollView.canCancelContentTouches = canCancelContentTouches
        
        drawerScrollView.backgroundColor = UIColor.clear
        drawerScrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        drawerScrollView.scrollsToTop = false
        drawerScrollView.touchDelegate = self
    }
    
    
    private func setupDrawerShadowView() {
        
        drawerShadowView.layer.shadowOpacity = shadowOpacity
        drawerShadowView.layer.shadowRadius = shadowRadius
        drawerShadowView.layer.shadowOffset = shadowOffset
        drawerShadowView.backgroundColor = UIColor.clear
    }
    
    
    private func setupBackgroundDimmingView() {
        
        backgroundDimmingView.backgroundColor = backgroundDimmingColor
        backgroundDimmingView.isUserInteractionEnabled = false
        backgroundDimmingView.alpha = 0.0
    }

    
    private func performViewDidLoadSetupThatsTotallyDifferentFromLoadView() {
        
        enforceCanScrollDrawer()
        setDrawerPosition(position: initialDrawerPosition, animated: false)
        scrollViewDidScroll(drawerScrollView)
        
        delegate?.drawerDisplayModeDidChange?(drawer: self)
        (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.drawerDisplayModeDidChange?(drawer: self)
        (primaryContentContainer as? PulleyPrimaryContentControllerDelegate)?.drawerDisplayModeDidChange?(drawer: self)
    }
    


    //-----------------------------
    // MARK: Private State Updates
    //-----------------------------
    private func enforceCanScrollDrawer() {
        
        guard isViewLoaded else { return }
        drawerScrollView.isScrollEnabled = allowsUserDrawerPositionChange && (supportedPositions.count > 1)
    }

    private func getStopList() -> [CGFloat] {
    
        var drawerStops = [CGFloat]()
        var collapsedHeight:CGFloat = kPulleyDefaultCollapsedHeight
        var partialRevealHeight:CGFloat = kPulleyDefaultPartialRevealHeight
        
        if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate {
            collapsedHeight = drawerVCCompliant.collapsedDrawerHeight?(bottomSafeArea: pulleySafeAreaInsets.bottom) ?? kPulleyDefaultCollapsedHeight
            partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight?(bottomSafeArea: pulleySafeAreaInsets.bottom) ?? kPulleyDefaultPartialRevealHeight
        }
        
        if supportedPositions.contains(.collapsed) {
            drawerStops.append(collapsedHeight)
        }
        
        if supportedPositions.contains(.partiallyRevealed) {
            drawerStops.append(partialRevealHeight)
        }
        
        if supportedPositions.contains(.open) {
            drawerStops.append((view.bounds.size.height - drawerTopInset - pulleySafeAreaInsets.top))
        }
        
        return drawerStops
    }

    /**
     Returns a masking path appropriate for the drawer content. Either
     an existing user-supplied mask from the `drawerContentViewController's`
     view will be returned, or the default Pulley mask with the requested
     rounded corners will be used.

     - parameter corners: The corners to round if there is no custom mask
     already applied to the `drawerContentViewController` view. If the
     `drawerContentViewController` has a custom mask (supplied by the
     user of this library), then the corners parameter will be ignored.
     */
    private func drawerMaskingPath(byRoundingCorners corners: UIRectCorner) -> UIBezierPath {
        // In lue of drawerContentViewController.view.layoutIfNeeded() whenever this function is called, if the viewController is loaded setNeedsLayout
        if drawerContentViewController.isViewLoaded {
            drawerContentViewController.view.setNeedsLayout()
        }

        let path: UIBezierPath
        if let customPath = (drawerContentViewController.view.layer.mask as? CAShapeLayer)?.path {
            path = UIBezierPath(cgPath: customPath)
        } else {
            path = UIBezierPath(roundedRect: drawerContentContainer.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: drawerCornerRadius, height:
                                                        drawerCornerRadius))
        }

        return path
    }
    
    private func maskDrawerVisualEffectView() {
        
        if let drawerBackgroundVisualEffectView = drawerBackgroundVisualEffectView {
            let path = drawerMaskingPath(byRoundingCorners: [.topLeft, .topRight])
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath

            drawerBackgroundVisualEffectView.layer.mask = maskLayer
        }
    }

    
    /**
     Mask backgroundDimmingView layer to avoid drawer background beeing darkened.
     */
    private func maskBackgroundDimmingView() {
        let cutoutHeight = 2 * drawerCornerRadius
        let maskHeight = backgroundDimmingView.bounds.size.height - cutoutHeight - drawerScrollView.contentSize.height
        let borderPath = drawerMaskingPath(byRoundingCorners: [.topLeft, .topRight])
        
        // This applys the boarder path transform to the minimum x of the content container for iPhone X size devices
        if let frame = drawerContentContainer.superview?.convert(drawerContentContainer.frame, to: self.view) {
            borderPath.apply(CGAffineTransform(translationX: frame.minX, y: maskHeight))
        } else  {
            borderPath.apply(CGAffineTransform(translationX: 0.0, y: maskHeight))
        }
        let maskLayer = CAShapeLayer()

        // Invert mask to cut away the bottom part of the dimming view
        borderPath.append(UIBezierPath(rect: backgroundDimmingView.bounds))
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        maskLayer.path = borderPath.cgPath
        backgroundDimmingView.layer.mask = maskLayer
    }
    
    
    open func prepareFeedbackGenerator() {

        if let generator = feedbackGenerator {
            generator.prepare()
        }
    }
    
    
    open func triggerFeedbackGenerator() {

        // prepareFeedbackGenerator() is also added to scrollViewWillEndDragging to improve time between haptic engine triggering feedback and the call to prepare.
        prepareFeedbackGenerator()
        (feedbackGenerator as? UIImpactFeedbackGenerator)?.impactOccurred()
        (feedbackGenerator as? UISelectionFeedbackGenerator)?.selectionChanged()
        (feedbackGenerator as? UINotificationFeedbackGenerator)?.notificationOccurred(.success)
    }
    
    
    /// Add a gesture recognizer to the drawer scrollview
    ///
    /// - Parameter gestureRecognizer: The gesture recognizer to add
    public func addDrawerGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        drawerScrollView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    /// Remove a gesture recognizer from the drawer scrollview
    ///
    /// - Parameter gestureRecognizer: The gesture recognizer to remove
    public func removeDrawerGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        drawerScrollView.removeGestureRecognizer(gestureRecognizer)
    }
    
    
    /// Bounce the drawer to get user attention. Note: Only works in .drawer display mode and when the drawer is in .collapsed or .partiallyRevealed position.
    ///
    /// - Parameters:
    ///   - bounceHeight: The height to bounce
    ///   - speedMultiplier: The multiplier to apply to the default speed of the animation. Note, default speed is 0.75.
    public func bounceDrawer(bounceHeight: CGFloat = 50.0, speedMultiplier: Double = 0.75) {
        
        guard drawerPosition == .collapsed || drawerPosition == .partiallyRevealed else {
            print("Pulley: Error: You can only bounce the drawer when it's in the collapsed or partially revealed position.")
            return
        }
        
        guard currentDisplayMode == .drawer else {
            print("Pulley: Error: You can only bounce the drawer when it's in the .drawer display mode.")
            return
        }
        
        let drawerStartingBounds = drawerScrollView.bounds

        let factors: [CGFloat] = [0, 32, 60, 83, 100, 114, 124, 128, 128, 124, 114, 100, 83, 60, 32,
            0, 24, 42, 54, 62, 64, 62, 54, 42, 24, 0, 18, 28, 32, 28, 18, 0]
        
        var values = [CGFloat]()
        
        for factor in factors
        {
            let positionOffset = (factor / 128.0) * bounceHeight
            values.append(drawerStartingBounds.origin.y + positionOffset)
        }
        
        let animation = CAKeyframeAnimation(keyPath: "bounds.origin.y")
        animation.repeatCount = 1
        animation.duration = (32.0/30.0) * speedMultiplier
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.values = values
        animation.isRemovedOnCompletion = true
        animation.autoreverses = false

        drawerScrollView.layer.add(animation, forKey: "bounceAnimation")
    }
    
    /**
     Get a frame for moving backgroundDimmingView according to drawer position.
     
     - parameter drawerPosition: drawer position in points
     
     - returns: a frame for moving backgroundDimmingView according to drawer position
     */
    private func backgroundDimmingViewFrameForDrawerPosition(_ drawerPosition: CGFloat) -> CGRect {
        let cutoutHeight = (2 * drawerCornerRadius)
        var backgroundDimmingViewFrame = backgroundDimmingView.frame
        backgroundDimmingViewFrame.origin.y = 0 - drawerPosition + cutoutHeight

        return backgroundDimmingViewFrame
    }
    
    private func syncDrawerContentViewSizeToMatchScrollPositionForSideDisplayMode() {
        
        guard currentDisplayMode == .panel || currentDisplayMode == .compact else {
            return
        }

        let lowestStop = getStopList().min() ?? 0
         
        drawerContentContainer.frame = CGRect(x: 0.0, y: drawerScrollView.bounds.height - lowestStop , width: drawerScrollView.bounds.width, height: drawerScrollView.contentOffset.y + lowestStop)
        drawerBackgroundVisualEffectView?.frame = drawerContentContainer.frame
        drawerShadowView.frame = drawerContentContainer.frame
        
        // Update rounding mask and shadows
        let borderPath = drawerMaskingPath(byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight]).cgPath

        let cardMaskLayer = CAShapeLayer()
        cardMaskLayer.path = borderPath
        cardMaskLayer.frame = drawerContentContainer.bounds
        cardMaskLayer.fillColor = UIColor.white.cgColor
        cardMaskLayer.backgroundColor = UIColor.clear.cgColor
        drawerContentContainer.layer.mask = cardMaskLayer

        maskDrawerVisualEffectView()
        
        if !isAnimatingDrawerPosition
            || borderPath.boundingBox.height < drawerShadowView.layer.shadowPath?.boundingBox.height ?? 0.0 {
            drawerShadowView.layer.shadowPath = borderPath
        }
    }

    
    //-----------------------------
    // MARK: Configuration Updates
    //-----------------------------
    
    /**
     Set the drawer position, with an option to animate.
     
     - parameter position: The position to set the drawer to.
     - parameter animated: Whether or not to animate the change. (Default: true)
     - parameter completion: A block object to be executed when the animation sequence ends. The Bool indicates whether or not the animations actually finished before the completion handler was called. (Default: nil)
     */
    public func setDrawerPosition(
        position: PulleyPosition,
        animated: Bool,
        completion: PulleyAnimationCompletionBlock? = nil
    ) {
        
        guard supportedPositions.contains(position) else {
            
            print("PulleyViewController: You can't set the drawer position to something not supported by the current view controller contained in the drawer. If you haven't already, you may need to implement the PulleyDrawerViewControllerDelegate.")
            return
        }
        
        drawerPosition = position
        
        var collapsedHeight:CGFloat = kPulleyDefaultCollapsedHeight
        var partialRevealHeight:CGFloat = kPulleyDefaultPartialRevealHeight
        
        if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate {
            collapsedHeight = drawerVCCompliant.collapsedDrawerHeight?(bottomSafeArea: pulleySafeAreaInsets.bottom) ?? kPulleyDefaultCollapsedHeight
            partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight?(bottomSafeArea: pulleySafeAreaInsets.bottom) ?? kPulleyDefaultPartialRevealHeight
        }

        let stopToMoveTo: CGFloat
        
        switch drawerPosition {
        case .collapsed: stopToMoveTo = collapsedHeight
        case .partiallyRevealed: stopToMoveTo = partialRevealHeight
        case .open: stopToMoveTo = heightOfOpenDrawer
        case .closed: stopToMoveTo = 0
        default: stopToMoveTo = 0
        }
        
        let lowestStop = getStopList().min() ?? 0
        
        triggerFeedbackGenerator()
        
        if animated,
            view.window != nil {
            
            isAnimatingDrawerPosition = true
            UIView.animate(withDuration: animationDuration,
                           delay: animationDelay,
                           usingSpringWithDamping:
                            animationSpringDamping,
                           initialSpringVelocity: animationSpringInitialVelocity,
                           options: animationOptions,
                           animations: {
                [weak self] () -> Void in
                
                self?.drawerScrollView.setContentOffset(CGPoint(x: 0, y: stopToMoveTo - lowestStop), animated: false)
                
                // Move backgroundDimmingView to avoid drawer background being darkened
                self?.backgroundDimmingView.frame = self?.backgroundDimmingViewFrameForDrawerPosition(stopToMoveTo) ?? CGRect.zero
                
                if let drawer = self {
                    drawer.delegate?.drawerPositionDidChange?(drawer: drawer, bottomSafeArea: self?.pulleySafeAreaInsets.bottom ?? 0.0)
                    (drawer.drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.drawerPositionDidChange?(drawer: drawer, bottomSafeArea: self?.pulleySafeAreaInsets.bottom ?? 0.0)
                    (drawer.primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.drawerPositionDidChange?(drawer: drawer, bottomSafeArea: self?.pulleySafeAreaInsets.bottom ?? 0.0)
                    
                    // Fix the bouncy drawer bug on iPad and Mac
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        drawer.view.layoutIfNeeded()
                    }
                }
            }, completion: { [weak self] (completed) in
                    
                    self?.isAnimatingDrawerPosition = false
                    self?.syncDrawerContentViewSizeToMatchScrollPositionForSideDisplayMode()
                    
                    completion?(completed)
            })
        } else {
            drawerScrollView.setContentOffset(CGPoint(x: 0, y: stopToMoveTo - lowestStop), animated: false)
            
            // Move backgroundDimmingView to avoid drawer background being darkened
            backgroundDimmingView.frame = backgroundDimmingViewFrameForDrawerPosition(stopToMoveTo)
            
            delegate?.drawerPositionDidChange?(drawer: self, bottomSafeArea: pulleySafeAreaInsets.bottom)
            (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.drawerPositionDidChange?(drawer: self, bottomSafeArea: pulleySafeAreaInsets.bottom)
            (primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.drawerPositionDidChange?(drawer: self, bottomSafeArea: pulleySafeAreaInsets.bottom)

            completion?(true)
        }
    }
    

    /**
     Change the current primary content view controller (The one behind the drawer)
     
     - parameter controller: The controller to replace it with
     - parameter animated:   Whether or not to animate the change. Defaults to true.
     - parameter completion: A block object to be executed when the animation sequence ends. The Bool indicates whether or not the animations actually finished before the completion handler was called.
     */
    public func setPrimaryContentViewController(controller: UIViewController, animated: Bool = true, completion: PulleyAnimationCompletionBlock?)
    {
        // Account for transition issue in iOS 11
        controller.view.frame = primaryContentContainer.bounds
        controller.view.layoutIfNeeded()
        
        if animated {
            UIView.transition(
                with: primaryContentContainer,
                duration: animationDuration,
                options: .transitionCrossDissolve,
                animations: { [weak self] () -> Void in
                
                self?.primaryContentViewController = controller
                
                }, completion: { (completed) in
                    
                    completion?(completed)
            })
        }
        else
        {
            primaryContentViewController = controller
            completion?(true)
        }
    }
    
    /**
     Change the current primary content view controller (The one behind the drawer). This method exists for backwards compatibility.
     
     - parameter controller: The controller to replace it with
     - parameter animated:   Whether or not to animate the change. Defaults to true.
     */
    public func setPrimaryContentViewController(controller: UIViewController, animated: Bool = true)
    {
        setPrimaryContentViewController(controller: controller, animated: animated, completion: nil)
    }
    
    /**
     Change the current drawer content view controller (The one inside the drawer)
     
     - parameter controller: The controller to replace it with
     - parameter position: The initial position of the contoller
     - parameter animated:   Whether or not to animate the change.
     - parameter completion: A block object to be executed when the animation sequence ends. The Bool indicates whether or not the animations actually finished before the completion handler was called.
     */
    public func setDrawerContentViewController(
        controller: UIViewController,
        position: PulleyPosition? = nil,
        animated: Bool = true,
        completion: PulleyAnimationCompletionBlock?
    ) {
        // Account for transition issue in iOS 11
        controller.view.frame = drawerContentContainer.bounds
        controller.view.layoutIfNeeded()
        
        if animated {
            UIView.transition(with: drawerContentContainer, duration: animationDuration, options: .transitionCrossDissolve, animations: { [weak self] () -> Void in
                
                self?.drawerContentViewController = controller
                self?.setDrawerPosition(position: position ?? (self?.drawerPosition ?? .collapsed), animated: false)
            }, completion: { (completed) in
                completion?(completed)
            })
        } else {
            drawerContentViewController = controller
            
            setDrawerPosition(position: position ?? drawerPosition, animated: false)
            completion?(true)
        }
    }
    
    /**
     Change the current drawer content view controller (The one inside the drawer). This method exists for backwards compatibility.
     
     - parameter controller: The controller to replace it with
     - parameter animated:   Whether or not to animate the change.
     - parameter completion: A block object to be executed when the animation sequence ends. The Bool indicates whether or not the animations actually finished before the completion handler was called.
     */
    
    public func setDrawerContentViewController(
        controller: UIViewController,
        animated: Bool = true,
        completion: PulleyAnimationCompletionBlock?
    ) {
        setDrawerContentViewController(controller: controller, position: nil, animated: animated,  completion: completion)
    
    }
    
    /**
     Change the current drawer content view controller (The one inside the drawer). This method exists for backwards compatibility.
     
     - parameter controller: The controller to replace it with
     - parameter animated:   Whether or not to animate the change.
     */
    public func setDrawerContentViewController(controller: UIViewController, animated: Bool = true) {
        setDrawerContentViewController(
            controller: controller,
            position: nil,
            animated: animated,
            completion: nil
        )
    }
    
    /**
     Update the supported drawer positions allows by the Pulley Drawer
     */
    public func setNeedsSupportedDrawerPositionsUpdate() {
        if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate {
            if let setSupportedDrawerPositions = drawerVCCompliant.supportedDrawerPositions?() {
                supportedPositions = self.currentDisplayMode == .compact ? setSupportedDrawerPositions.filter(PulleyPosition.compact.contains) : setSupportedDrawerPositions
            } else {
                supportedPositions = self.currentDisplayMode == .compact ?  PulleyPosition.compact : PulleyPosition.all
            }
        } else {
            supportedPositions = self.currentDisplayMode == .compact ?  PulleyPosition.compact : PulleyPosition.all
        }
    }
    
    
    
    //---------------
    // MARK: Actions
    //---------------
    @objc func dimmingViewTapRecognizerAction(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer == dimmingViewTapRecognizer {
            if gestureRecognizer.state == .ended {
                setDrawerPosition(position: positionWhenDimmingBackgroundIsTapped, animated: true)
            }
        }
    }
    
    // MARK: Propogate child view controller style / status bar presentation based on drawer state
    
    override open var childForStatusBarStyle: UIViewController? {
        get {
            
            if drawerPosition == .open {
                return drawerContentViewController
            }
            
            return primaryContentViewController
        }
    }
    
    override open var childForStatusBarHidden: UIViewController? {
        get {
            if drawerPosition == .open {
                return drawerContentViewController
            }
            
            return primaryContentViewController
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.notifyWhenInteractionChanges {
            [weak self] (context) in
            guard let currentPosition = self?.drawerPosition else { return }
            self?.setDrawerPosition(position: currentPosition, animated: false)
        }
    }
    
    // MARK: PulleyDrawerViewControllerDelegate implementation for nested Pulley view controllers in drawers. Implemented here, rather than an extension because overriding extensions in subclasses isn't good practice. Some developers want to subclass Pulley and customize these behaviors, so we'll move them here.
    
    open func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate,
            let collapsedHeight = drawerVCCompliant.collapsedDrawerHeight?(bottomSafeArea: bottomSafeArea) {
            return collapsedHeight
        } else {
            return 68.0 + bottomSafeArea
        }
    }
    
    open func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate,
            let partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight?(bottomSafeArea: bottomSafeArea) {
            return partialRevealHeight
        } else {
            return 264.0 + bottomSafeArea
        }
    }
    
    open func supportedDrawerPositions() -> [PulleyPosition] {
        if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate,
            let supportedPositions = drawerVCCompliant.supportedDrawerPositions?() {
            return (self.currentDisplayMode == .compact ? supportedPositions.filter(PulleyPosition.compact.contains) : supportedPositions)
        } else {
            return (currentDisplayMode == .compact ? PulleyPosition.compact : PulleyPosition.all)
        }
    }
    
    open func drawerPositionDidChange(drawer: PullUpController, bottomSafeArea: CGFloat) {
        if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate {
            drawerVCCompliant.drawerPositionDidChange?(drawer: drawer, bottomSafeArea: bottomSafeArea)
        }
    }
    
    open func makeUIAdjustmentsForFullscreen(progress: CGFloat, bottomSafeArea: CGFloat) {
        if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate {
            drawerVCCompliant.makeUIAdjustmentsForFullscreen?(progress: progress, bottomSafeArea: bottomSafeArea)
        }
    }
    
    open func drawerChangedDistanceFromBottom(drawer: PullUpController, distance: CGFloat, bottomSafeArea: CGFloat) {
        if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate {
            drawerVCCompliant.drawerChangedDistanceFromBottom?(drawer: drawer, distance: distance, bottomSafeArea: bottomSafeArea)
        }
    }
}




//--------------------------------------------------
//  MARK: - Pulley Passthrough ScrollView Delegate
//--------------------------------------------------
extension PullUpController: @preconcurrency PulleyPassthroughScrollViewDelegate {
    
    func shouldTouchPassthroughScrollView(scrollView: PullUpPassthroughScrollView, point: CGPoint) -> Bool {
        return !drawerContentContainer.bounds.contains(drawerContentContainer.convert(point, from: scrollView))
    }
    
    func viewToReceiveTouch(scrollView: PullUpPassthroughScrollView, point: CGPoint) -> UIView {
        if currentDisplayMode == .drawer {
            if drawerPosition == .open {
                return backgroundDimmingView
            }
            
            return primaryContentContainer
            
        } else {
            if drawerContentContainer.bounds.contains(drawerContentContainer.convert(point, from: scrollView)) {
                return drawerContentViewController.view
            }
            
            return primaryContentContainer
        }
    }
}



//--------------------------------
//  MARK: - UIScrollView Delegate
//--------------------------------
extension PullUpController: UIScrollViewDelegate {

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        
        if scrollView == drawerScrollView {
            // Find the closest anchor point and snap there.
            var collapsedHeight:CGFloat = kPulleyDefaultCollapsedHeight
            var partialRevealHeight:CGFloat = kPulleyDefaultPartialRevealHeight
            
            if let drawerVCCompliant = drawerContentViewController as? PulleyDrawerViewControllerDelegate {
                collapsedHeight = drawerVCCompliant.collapsedDrawerHeight?(bottomSafeArea: pulleySafeAreaInsets.bottom) ?? kPulleyDefaultCollapsedHeight
                partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight?(bottomSafeArea: pulleySafeAreaInsets.bottom) ?? kPulleyDefaultPartialRevealHeight
            }

            var drawerStops: [CGFloat] = [CGFloat]()
            var currentDrawerPositionStop: CGFloat = 0.0
            
            if supportedPositions.contains(.open) {
                drawerStops.append(heightOfOpenDrawer)
                
                if drawerPosition == .open {
                    currentDrawerPositionStop = drawerStops.last!
                }
            }
            
            if supportedPositions.contains(.partiallyRevealed) {
                drawerStops.append(partialRevealHeight)
                
                if drawerPosition == .partiallyRevealed {
                    currentDrawerPositionStop = drawerStops.last!
                }
            }
            
            if supportedPositions.contains(.collapsed) {
                drawerStops.append(collapsedHeight)
                
                if drawerPosition == .collapsed {
                    currentDrawerPositionStop = drawerStops.last!
                }
            }
            
            let lowestStop = drawerStops.min() ?? 0
            
            let distanceFromBottomOfView = lowestStop + lastDragTargetContentOffset.y
            
            var currentClosestStop = lowestStop
            
            for currentStop in drawerStops {
                if abs(currentStop - distanceFromBottomOfView) < abs(currentClosestStop - distanceFromBottomOfView) {
                    currentClosestStop = currentStop
                }
            }
            
            var closestValidDrawerPosition: PulleyPosition = drawerPosition
            
            if abs(Float(currentClosestStop - heightOfOpenDrawer)) <= Float.ulpOfOne && supportedPositions.contains(.open) {
                closestValidDrawerPosition = .open
            } else if abs(Float(currentClosestStop - collapsedHeight)) <= Float.ulpOfOne && supportedPositions.contains(.collapsed) {
                closestValidDrawerPosition = .collapsed
            } else if supportedPositions.contains(.partiallyRevealed) {
                closestValidDrawerPosition = .partiallyRevealed
            }
            
            let snapModeToUse: PulleySnapMode = closestValidDrawerPosition == drawerPosition ? snapMode : .nearestPosition
            
            switch snapModeToUse {
            case .nearestPosition: setDrawerPosition(position: closestValidDrawerPosition, animated: true)
            case .nearestPositionUnlessExceeded(let threshold):
                
                let distance = currentDrawerPositionStop - distanceFromBottomOfView
                var positionToSnapTo: PulleyPosition = drawerPosition

                if abs(distance) > threshold {
                    if distance < 0 {
                        let orderedSupportedDrawerPositions = supportedPositions.sorted(by: { $0.rawValue < $1.rawValue }).filter({ $0 != .closed })

                        for position in orderedSupportedDrawerPositions {
                            if position.rawValue > drawerPosition.rawValue {
                                positionToSnapTo = position
                                break
                            }
                        }
                    } else {
                        let orderedSupportedDrawerPositions = supportedPositions.sorted(by: { $0.rawValue > $1.rawValue }).filter({ $0 != .closed })
                        
                        for position in orderedSupportedDrawerPositions {
                            if position.rawValue < drawerPosition.rawValue  {
                                positionToSnapTo = position
                                break
                            }
                        }
                    }
                }
                
                setDrawerPosition(position: positionToSnapTo, animated: true)
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == drawerScrollView {
            self.isChangingDrawerPosition = true
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        prepareFeedbackGenerator()

        if scrollView == drawerScrollView {
            lastDragTargetContentOffset = targetContentOffset.pointee
            
            // Halt intertia
            targetContentOffset.pointee = scrollView.contentOffset
            isChangingDrawerPosition = false
        }
    }
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == drawerScrollView {
            let partialRevealHeight: CGFloat = (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.partialRevealDrawerHeight?(bottomSafeArea: pulleySafeAreaInsets.bottom) ?? kPulleyDefaultPartialRevealHeight

            let lowestStop = getStopList().min() ?? 0
            
            if (scrollView.contentOffset.y - pulleySafeAreaInsets.bottom) > partialRevealHeight - lowestStop && supportedPositions.contains(.open) {
                // Calculate percentage between partial and full reveal
                let fullRevealHeight = heightOfOpenDrawer
                let progress: CGFloat
                if fullRevealHeight == partialRevealHeight {
                    progress = 1.0
                } else {
                    progress = (scrollView.contentOffset.y - (partialRevealHeight - lowestStop)) / (fullRevealHeight - (partialRevealHeight))
                }
                
                delegate?.makeUIAdjustmentsForFullscreen?(progress: progress, bottomSafeArea: pulleySafeAreaInsets.bottom)
                (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: progress, bottomSafeArea: pulleySafeAreaInsets.bottom)
                (primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: progress, bottomSafeArea: pulleySafeAreaInsets.bottom)
                
                backgroundDimmingView.alpha = progress * backgroundDimmingOpacity
                
                backgroundDimmingView.isUserInteractionEnabled = true
                
            } else {
                if backgroundDimmingView.alpha >= 0.001 {
                    backgroundDimmingView.alpha = 0.0
                    
                    delegate?.makeUIAdjustmentsForFullscreen?(progress: 0.0, bottomSafeArea: pulleySafeAreaInsets.bottom)
                    (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: 0.0, bottomSafeArea: pulleySafeAreaInsets.bottom)
                    (primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: 0.0, bottomSafeArea: pulleySafeAreaInsets.bottom)
                    
                    backgroundDimmingView.isUserInteractionEnabled = false
                }
            }
            
            delegate?.drawerChangedDistanceFromBottom?(drawer: self, distance: scrollView.contentOffset.y + lowestStop, bottomSafeArea: pulleySafeAreaInsets.bottom)
            (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.drawerChangedDistanceFromBottom?(drawer: self, distance: scrollView.contentOffset.y + lowestStop, bottomSafeArea: pulleySafeAreaInsets.bottom)
            (primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.drawerChangedDistanceFromBottom?(drawer: self, distance: scrollView.contentOffset.y + lowestStop, bottomSafeArea: pulleySafeAreaInsets.bottom)
            
            // Move backgroundDimmingView to avoid drawer background beeing darkened
            backgroundDimmingView.frame = backgroundDimmingViewFrameForDrawerPosition(scrollView.contentOffset.y + lowestStop)
            
            syncDrawerContentViewSizeToMatchScrollPositionForSideDisplayMode()
        }
    }
}
