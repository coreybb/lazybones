import UIKit
import Combine

protocol KeyboardResponsive: UIView {
    var keyboardEventPublisher: KeyboardEventPublishing { get }
    var keyboardResponsiveSubviews: [UIView] { get set }
    var cancellables: Set<AnyCancellable> { get set }
    func handleKeyboardWillShow(with height: CGFloat)
    func handleKeyboardWillHide()
}


//  MARK: - Default Implementation
extension KeyboardResponsive {
    
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
