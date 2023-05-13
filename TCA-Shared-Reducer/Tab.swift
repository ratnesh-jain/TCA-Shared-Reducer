//
//  Tab.swift
//  TCA-Shared-Reducer
//
//  Created by Ratnesh Jain on 5/13/23.
//

import Foundation
import SwiftUI

enum Tab: String, Equatable {
    case listen
    case search
    
    @ViewBuilder
    var label: some View {
        switch self {
        case .listen:
            Label("Listen", systemImage: "music.note")
        case .search:
            Label("Search", systemImage: "magnifyingglass")
        }
    }
}
