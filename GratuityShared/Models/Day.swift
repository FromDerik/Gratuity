//
//  Day.swift
//  Tipped
//
//  Created by Derik Malcolm on 9/1/2022.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

import Foundation

public struct Day: Identifiable, Equatable {
    public var id = UUID()
    
    public var tips: [Tip]
    public let date: Date
    
    public init(tips: [Tip], date: Date) {
        self.tips = tips
        self.date = date
    }
}
