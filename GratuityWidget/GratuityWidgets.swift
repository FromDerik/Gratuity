//
//  GratuityWidgets.swift
//  GratuityWidgetExtension
//
//  Created by Derik Malcolm on 9/1/2022.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct GratuityWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TodaysTotalWidget()
    }
}
