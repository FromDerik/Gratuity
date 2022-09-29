//
//  ChartData.swift
//  Gratuity
//
//  Created by Derik Malcolm on 9/9/22.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

import Foundation

struct ChartData: Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var amount: Double
    var unit: Calendar.Component
}
