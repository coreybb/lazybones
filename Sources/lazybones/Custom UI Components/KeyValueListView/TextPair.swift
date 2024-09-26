//
//  TextPair.swift
//  lazybones
//
//  Created by Corey Beebe on 9/26/24.
//


import Foundation


public struct TextPair {
    
    let id: UUID
    let primary: String
    let secondary: String
    
    init(id: UUID? = nil, primary: String, secondary: String) {
        self.id = id ?? UUID()
        self.primary = primary
        self.secondary = secondary
    }
}
