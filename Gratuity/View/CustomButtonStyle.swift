//
//  CustomButtonStyle.swift
//  Gratuity
//
//  Created by Derik Malcolm on 9/10/22.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

import SwiftUI
import GratuityShared

struct CustomButtonStyle: ButtonStyle {
    @AppStorage("appTint", store: .init(suiteName: "group.com.fromderik.Gratuity")) var appTint: Color = .blue
    var pressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(appTint)
            .padding(5)
            .background(
                Group {
                    if pressed {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(UIColor.secondarySystemFill))
                    }
                }
            )
    }
}
