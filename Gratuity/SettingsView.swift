//
//  SettingsView.swift
//  SettingsView
//
//  Created by Derik Malcolm on 9/1/2022.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

import SwiftUI

extension Color {
    public static var allColors: [Color] {
        [
            
        ]
    }
}

struct SettingsView: View {
    @State private var tintColor = Color.blue
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Tint Color", selection: $tintColor) {
                        ForEach(Color.allColors, id: \.self) { color in
                            HStack(spacing: 10) {
                                color
                                    .frame(width: 30, height: 30)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                Text(color.description)
                            }
                        }
//                        .navigationBarTitle("Tint Color")
                    }
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Button("Modal always shown") {}
            .sheet(isPresented: .constant(true)) {
                SettingsView()
            }
    }
}
