import UIKit
import Combine


/// A protocol that provides keyboard responsiveness to UIViews.
/// Conforming views can easily handle keyboard show/hide events and adjust their subviews accordingly.
public protocol LazyKeyboardResponsive: UIView {
    
    /// The publisher that emits keyboard events.
    /// This should be an instance of a type conforming to `LazyKeyboardEventPublishing`.
    var keyboardEventPublisher: LazyKeyboardEventPublishing { get }
    
    /// An array of subviews that should be adjusted when the keyboard appears or disappears.
    /// These views will be moved up when the keyboard shows and back to their original position when it hides.
    var keyboardResponsiveSubviews: [UIView] { get set }
    
    /// A set to store and manage subscriptions to keyboard events as Combine cancellables.
    var cancellables: Set<AnyCancellable> { get set }
    
    /// Sets up the keyboard event handling.
    /// Call this method in the initializer of your view to start observing keyboard events.
    func setupKeyboardHandling()
    
    /// Called when the keyboard is about to show.
    /// - Parameter height: The height of the keyboard.
    /// Override this method to customize behavior when the keyboard appears.
    func handleKeyboardWillShow(with height: CGFloat)
    
    /// Called when the keyboard is about to hide.
    /// Override this method to customize behavior when the keyboard disappears.
    func handleKeyboardWillHide()
}


//  MARK: - Default Implementation
public extension LazyKeyboardResponsive {
    
    func setupKeyboardHandling() {
        
        keyboardEventPublisher.keyboardWillShowPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] height in
                self?.handleKeyboardWillShow(with: height)
            }
            .store(in: &cancellables)
        
        keyboardEventPublisher.keyboardWillHidePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handleKeyboardWillHide()
            }
            .store(in: &cancellables)
    }
    
    
    func handleKeyboardWillShow(with height: CGFloat) {
        performKeyboardResponsiveSubviewsAnimations { [weak self] in
            self?.keyboardResponsiveSubviews.forEach {
                $0.transform = CGAffineTransform(translationX: 0, y: -height)
            }
        }
    }
    
    
    func handleKeyboardWillHide() {
        performKeyboardResponsiveSubviewsAnimations { [weak self] in
            self?.keyboardResponsiveSubviews.forEach {
                $0.transform = .identity
            }
        }
    }
}



//  MARK: - Private API
extension LazyKeyboardResponsive {
    
    private func performKeyboardResponsiveSubviewsAnimations(_ animations: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.7,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1,
            options: .curveEaseOut,
            animations: animations
        )
    }
}




// MARK: - Usage Example

/*
/// Example implementation of a custom view conforming to LazyKeyboardResponsive
class ExampleKeyboardResponsiveView: UIView, LazyKeyboardResponsive {
    // MARK: - LazyKeyboardResponsive Protocol Requirements
    
    var keyboardEventPublisher: LazyKeyboardEventPublishing
    var keyboardResponsiveSubviews: [UIView] = []
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - UI Elements
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Submit", for: .normal)
        return button
    }()
    
    // MARK: - Initialization
    
    init(keyboardEventPublisher: LazyKeyboardEventPublishing) {
        self.keyboardEventPublisher = keyboardEventPublisher
        super.init(frame: .zero)
        setupUI()
        setupKeyboardHandling()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(textView)
        addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 100),
            
            submitButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add the button to keyboardResponsiveSubviews
        keyboardResponsiveSubviews = [submitButton]
    }
    
    // MARK: - LazyKeyboardResponsive Methods
    
    // Override the default implementation if needed
    func handleKeyboardWillShow(with height: CGFloat) {
        super.handleKeyboardWillShow(with: height)
        // Add any additional custom behavior here
    }
    
    func handleKeyboardWillHide() {
        super.handleKeyboardWillHide()
        // Add any additional custom behavior here
    }
}

// Usage in a view controller:
class ExampleViewController: UIViewController {
    private let keyboardEventPublisher = LazyKeyboardEventPublisher()
    private lazy var keyboardResponsiveView = ExampleKeyboardResponsiveView(keyboardEventPublisher: keyboardEventPublisher)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(keyboardResponsiveView)
        
        // Set up constraints for keyboardResponsiveView
        keyboardResponsiveView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            keyboardResponsiveView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            keyboardResponsiveView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardResponsiveView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardResponsiveView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
*/
