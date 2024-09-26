import UIKit

public struct LabelPair {
    
    let id: UUID
    let primary: LazyLabel
    let secondary: LazyLabel
    
    @MainActor
    init(
        primaryStyle: (any LazyContentStyle)?,
        secondaryStyle: (any LazyContentStyle)?,
        textPair: TextPair
    ) {
        id = textPair.id
        primary = LazyLabel(style: primaryStyle, text: textPair.primary)
        secondary = LazyLabel(style: secondaryStyle, text: textPair.secondary)
    }
}
