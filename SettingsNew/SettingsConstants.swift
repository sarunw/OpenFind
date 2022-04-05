//
//  SettingsConstants.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum SettingsConstants {
    static var sidePadding = CGFloat(16)
    static var sectionCornerRadius = CGFloat(12)
    static var sectionSpacing = CGFloat(20)
    static var iconSize = CGSize(width: 24, height: 24)
    static var iconCornerRadius = CGFloat(6)
    
    
    static var descriptionFont = UIFont.preferredFont(forTextStyle: .footnote)
    static var iconFont = UIFont.preferredCustomFont(forTextStyle: .footnote, weight: .semibold)
    
    static var rowInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
}
