import UIKit
import Combine

protocol KeyboardEventPublishing {
    var keyboardWillShowPublisher: AnyPublisher<CGFloat, Never> { get }
    var keyboardWillHidePublisher: AnyPublisher<Void, Never> { get }
}


final class KeyboardEventPublisher: KeyboardEventPublishing {
    
    
    //  MARK: - Public Properties
    public lazy var keyboardWillShowPublisher: AnyPublisher<CGFloat, Never> = keyboardWillShowSubject.eraseToAnyPublisher()
    public lazy var keyboardWillHidePublisher: AnyPublisher<Void, Never> = keyboardWillHideSubject.eraseToAnyPublisher()
    
    
    
    //  MARK: - Private Properties
    private let keyboardWillShowSubject = PassthroughSubject<CGFloat, Never>()
    private let keyboardWillHideSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    

    //  MARK: - Init
    init() {
        setupNotificationObservers()
    }
    
    
    //  MARK: - Private API
    private func setupNotificationObservers() {
        setupKeyboardWillShowPublisher()
        setupKeyboardWillHidePublisher()
    }
    
    
    private func setupKeyboardWillShowPublisher() {
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                    return nil
                }
                return keyboardFrame.cgRectValue.height
            }
            .sink { [weak self] keyboardHeight in
                self?.keyboardWillShowSubject.send(keyboardHeight)
            }
            .store(in: &cancellables)
    }
    
    
    private func setupKeyboardWillHidePublisher() {
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.keyboardWillHideSubject.send()
            }
            .store(in: &cancellables)
    }
}
