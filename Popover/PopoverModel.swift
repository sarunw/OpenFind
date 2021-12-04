//
//  PopoverModel.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Combine
import SwiftUI

class PopoverModel: ObservableObject {
    @Published var popovers = [Popover]()
}

enum Popover: Identifiable {
    var id: UUID {
        let context = extractContext()
        return context.id
    }
    var frame: CGRect {
        let context = extractContext()
        switch context.position.anchor {
        case .topLeft:
            return CGRect(origin: context.position.origin - CGPoint(x: 0, y: context.size.height), size: context.size)
        case .topRight:
            return CGRect(origin: context.position.origin - CGPoint(x: 0, y: context.size.height), size: context.size)
        case .bottomLeft:
            return CGRect(origin: context.position.origin, size: context.size)
        case .bottomRight:
            return CGRect(origin: context.position.origin, size: context.size)
        }
    }
    var keepPresentedRects: [CGRect] {
        let context = extractContext()
        return context.keepPresentedRects
    }
    
    func extractContext() -> PopoverContext {
        switch self {
        case .fieldSettings(let configuration):
            return configuration.popoverContext
        }
    }
    
    case fieldSettings(PopoverConfiguration.FieldSettings)
    
}
struct PopoverConfiguration {
    struct FieldSettings {
        var popoverContext = PopoverContext()
        
        var defaultColor: UIColor = UIColor(hex: 0x00aeef)
        var selectedColor: UIColor = UIColor(hex: 0x00aeef)
        var alpha: CGFloat = 1
        
        var propertiesChanged: ((Self) -> Void)?
    }
}
struct PopoverContext: Identifiable {
    var id = UUID()
    
    /// position of the popover
    var position: Popover.Position = .init(anchor: .bottomLeft, origin: .zero)
    
    /// calculated from SwiftUI
    var size: CGSize = .zero
    
    /// if click in once of these rects, don't dismiss the popover. Otherwise, dismiss.
    var keepPresentedRects: [CGRect] = []
    
}
