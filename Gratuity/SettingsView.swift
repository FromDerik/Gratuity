//
//  SettingsView.swift
//  Gratuity
//
//  Created by Derik Malcolm on 9/1/2022.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @ObservedObject var viewModel = ViewModel()
    
    var allColors: [Color] {
        [
            .red,
            .orange,
            .yellow,
            .green,
            .teal,
            .blue,
            .purple,
            .pink
        ]
    }
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        ForEach(allColors, id: \.self) { color in
                            Group {
                                if color == viewModel.appTint {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title.bold())
                                        .foregroundColor(color)
                                } else {
                                    Circle()
                                        .foregroundColor(color)
                                }
                            }
                            .onTapGesture {
                                self.viewModel.appTint = color
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        }
                        
                        ColorPicker(selection: $viewModel.appTint) {
                            Text("")
                        }
                    }
                    
                } header: {
                    Text("App Tint")
                }
            }
            .navigationBarTitle("Settings")
        }
    }
}

extension SettingsView {
    class ViewModel: ObservableObject {
        @AppStorage("appTint", store: .init(suiteName: "group.com.fromderik.Gratuity")) var appTint: Color = .blue
    }
}
struct SettingsView_Previews: PreviewProvider {
    @State static var presented = true
    
    static var previews: some View {
        Button("Modal always shown") { presented.toggle() }
            .sheet(isPresented: $presented) {
                SettingsView()
            }
    }
}
