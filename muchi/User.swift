//
//  User.swift
//  muchi
//
//  Created by Manik Singh Sarmaal on 28/01/26.
//

import Foundation
import SwiftData

/// The User model stores the profile information collected during onboarding.
/// This data persists locally using SwiftData and is used throughout the app
/// to personalize the alarm experience.
@Model
final class User {
    var name: String
    
    var age: Int
    
    var createdAt: Date
    
    init(name: String, age: Int, createdAt: Date = Date()) {
        self.name = name
        self.age = age
        self.createdAt = createdAt
    }
}
