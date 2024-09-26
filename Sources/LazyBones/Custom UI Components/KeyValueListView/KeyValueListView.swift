import UIKit


/// A protocol that defines the interface for a key-value list view.
public protocol LazyKeyValueListViewProtocol: UIView {
    /// The type of content style used for styling labels.
    associatedtype StyleType: LazyContentStyle
    
    /// Initializes a new key-value list view.
    /// - Parameters:
    ///   - textPairs: An array of text pairs to display.
    ///   - primaryStyle: The style to apply to primary labels (optional).
    ///   - secondaryStyle: The style to apply to secondary labels (optional).
    ///   - interItemSpacing: The spacing between each key-value pair.
    ///   - intraItemSpacing: The spacing between the key and value labels.
    ///   - separatorType: The type of separator to use between pairs.
    ///   - axis: The axis along which the labels are laid out.
    init(textPairs: [TextPair],
         primaryStyle: StyleType?,
         secondaryStyle: StyleType?,
         interItemSpacing: CGFloat,
         intraItemSpacing: CGFloat,
         separatorType: LazyKeyValueListView.SeparatorType,
         axis: NSLayoutConstraint.Axis)
    
    /// Inserts a new label pair into the list view.
    /// - Parameters:
    ///   - textPair: The text pair to insert.
    ///   - index: The index at which to insert the new pair (optional).
    func insertNewLabelPair(from textPair: TextPair, at index: Int?)
    
    /// Updates the text of a label pair identified by its UUID.
    /// - Parameters:
    ///   - id: The UUID of the label pair to update.
    ///   - newPrimaryText: The new text for the primary label.
    ///   - newSecondaryText: The new text for the secondary label.
    func updateLabelPair(for id: UUID, with newPrimaryText: String, newSecondaryText: String)
    
    /// Updates the text of a label pair at a specific index.
    /// - Parameters:
    ///   - index: The index of the label pair to update.
    ///   - newPrimaryText: The new text for the primary label.
    ///   - newSecondaryText: The new text for the secondary label.
    func updateLabelPair(at index: Int, with newPrimaryText: String, newSecondaryText: String)
}



open class LazyKeyValueListView: UIView {
    
    // MARK: - Public Properties
    public lazy var parentStackView: LazyVStackView = {
        let views: [LazyStackView] = {
            switch separatorType {
            case .line: labelPairsWithSeparatorsStackView()
            case .none: labelPairsStackViews()
            }
        }()
        
        return LazyVStackView(
            views: views,
            spacing: interItemSpacing
        )
    }()
    
    public let padding: CGFloat = 16
    public let separatorThickness: CGFloat = 0.3
    public let interItemSpacing: CGFloat
    public let intraItemSpacing: CGFloat
    public private(set) var labelPairs: [LabelPair] = []
    public let separatorType: SeparatorType
    public let axis: NSLayoutConstraint.Axis
    public let textPairs: [TextPair]
    public let primaryStyle: (any LazyContentStyle)?
    public let secondaryStyle: (any LazyContentStyle)?
    public lazy var labelsStackViewAlignment: UIStackView.Alignment = (axis == .vertical) ? .leading : .top

    
    
    // MARK: - Init
    public init(
        textPairs: [TextPair],
        primaryStyle: (any LazyContentStyle)? = nil,
        secondaryStyle: (any LazyContentStyle)? = nil,
        interItemSpacing: CGFloat = 16,
        intraItemSpacing: CGFloat = 8,
        separatorType: SeparatorType = .none,
        axis: NSLayoutConstraint.Axis
    ) {
        self.textPairs = textPairs
        self.primaryStyle = primaryStyle
        self.secondaryStyle = secondaryStyle
        self.interItemSpacing = interItemSpacing
        self.intraItemSpacing = intraItemSpacing
        self.separatorType = separatorType
        self.axis = axis
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layoutUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    
    
    //  MARK: - Public API
    /// Override this method to specify a custom layout.
    public func layoutUI() {
        layoutParentStackView()
    }
    
    
    
    //  Actions
    open func insertNewLabelPair(from textPair: TextPair, at index: Int? = nil) {
        
        parentStackView.insertArrangedSubview(
            labelPairsStackView(
                for: newLabelPair(for: textPair)
            ),
            at: index ?? parentStackView.subviews.endIndex
        )
        
        assert(
            labelPairs.count == parentStackView.arrangedSubviews.count,
            "Mismatch between labelPairs array count and parentStackView arrangedSubviews count."
        )
    }
    

    open func updateLabelPair(for id: UUID, with newPrimaryText: String, newSecondaryText: String) {
        
        updateLabel(.primary, for: id, with: newPrimaryText)
        updateLabel(.secondary, for: id, with: newSecondaryText)
    }
    
    
    open func updateLabelPair(at index: Int, with newPrimaryText: String, newSecondaryText: String) {

        updateLabel(.primary, at: index, with: newPrimaryText)
        updateLabel(.secondary, at: index, with: newSecondaryText)
    }
    

    open func updateLabel(_ type: LabelType, at index: Int, with newText: String) {
        
        guard handleOutOfRangeIndex(index) else { return }
        let labelPair: LabelPair = labelPairs[index]
        
        switch type {
        case .primary: labelPair.primary.text = newText
        case .secondary: labelPair.secondary.text = newText
        }
    }
    
    
    open func updateLabel(_ type: LabelType, for pairID: UUID, with newText: String) {
        
        guard let labelPair: LabelPair = labelPair(matching: pairID) else {
            print("No label pair with id: \(pairID)")
            return
        }
        
        switch type {
        case .primary: labelPair.primary.text = newText
        case .secondary: labelPair.secondary.text = newText
        }
    }
    
    
    
    //  Helpers
    open func labelPair(matching id: UUID) -> LabelPair? {
        labelPairs.first { $0.id == id }
    }
    
    
    open func validLabelPairIndex(for i: Int?) -> Int {
        
        guard let index: Int = i else { return labelPairs.endIndex }
        guard handleOutOfRangeIndex(index) else { return labelPairs.endIndex }
        return index
    }
    
    
    open func handleOutOfRangeIndex(_ index: Int) -> Bool {
        
        switch labelPairIndexIsInRange(index) {
        case true: return true
        case false:
            print("The specified index \(index) is out of range.")
            return false
        }
    }
    
    
    open func labelPairIndexIsInRange(_ i: Int) -> Bool {
        i <= labelPairs.endIndex
    }
    
    
    public enum SeparatorType {
        case line, none
    }
    
    public enum LabelType {
        case primary, secondary
    }
    
    
    
    //  Components
    open func labelPairsWithSeparatorsStackView() -> [LazyVStackView] {
        
        let stackViews = labelPairsStackViews()
        
        return stackViews.enumerated().map { (index, stackView) in
            if index == stackViews.count - 1 {
                return LazyVStackView(views: [stackView], spacing: intraItemSpacing)
            }
            
            return LazyVStackView(
                views: [
                    stackView,
                    LazyLineView(orientation: .horizontal, thickness: separatorThickness)
                ],
                spacing: 8
            )
        }
    }

    
    open func labelPairsStackViews() -> [LazyStackView] {
        textPairs.map {
            labelPairsStackView(
                for: newLabelPair(for: $0)
            )
        }
    }
    

    open func labelPairsStackView(for labelPair: LabelPair) -> LazyStackView {
        
        var views: [UIView] = [labelPair.primary, labelPair.secondary]
        let paddingBetweenLabels: CGFloat = 8

        if axis == .horizontal {
            views.append(
                LazySpacerView(width: padding, height: nil)
            )
        }
        
        return LazyStackView(
            views: views,
            axis: axis,
            spacing: paddingBetweenLabels,
            alignment: labelsStackViewAlignment
        )
    }
    
    
    open func newLabelPair(for textPair: TextPair, at index: Int? = nil) -> LabelPair {
        
        let labelPair = LabelPair(
            primaryStyle: primaryStyle,
            secondaryStyle: secondaryStyle,
            textPair: textPair
        )
        labelPairs.insert(labelPair, at: validLabelPairIndex(for: index))
        return labelPair
    }
    
    
    open func layoutParentStackView() {
        
        let rightPadding: CGFloat = 0
        
        addSubview(parentStackView)
        parentStackView.fillSuperview(
            padding: UIEdgeInsets(
                top: padding,
                left: padding,
                bottom: padding,
                right: rightPadding
            )
        )
    }
}
