//
//  EditTipView.swift
//  Gratuity
//
//  Created by Derik Malcolm on 9/1/2022.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

// AEE5081A-F449-4365-8632-376AB6FEE6D3

import SwiftUI
import GratuityShared

struct EditTipView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState private var isAmountFocused: Bool
    
    @ObservedObject var viewModel: ViewModel
    @EnvironmentObject var dataManager: DataManager
    
    init(tip: Tip) {
        self.viewModel = ViewModel(tip: tip)
    }
    
    var body: some View {
        let binding = Binding<String>(get: {
            self.viewModel.amount
        }, set: {
            self.viewModel.amount = $0.currencyInputFormatting()
        })
        
        return NavigationView {
            Form {
                Section {
                    TextField("Amount", text: binding)
                        .keyboardType(.numberPad)
                        .focused($isAmountFocused)
                        .scrollDismissesKeyboard(.immediately)
                        .onSubmit {
                            isAmountFocused.toggle()
                        }
                } header: {
                    Text("Amount")
                }
                
                Section {
                    TextField("Comment", text: $viewModel.comment)
                } header: {
                    Text("Comment")
                }
                
            }
            .navigationTitle("Add Tip")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button(action: save) {
                    Group {
                        HStack {
                            Spacer()
                            Text("Save")
                                .frame(height: 50)
                            Spacer()
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 25)
                        .fill(viewModel.appTint)
                    )
                    .foregroundColor(Color(uiColor: .systemBackground))
                    .padding()
                }
            }
        }
        .onAppear {
            isAmountFocused = true
        }
    }
    
    func save() {
        guard let amount = NumberFormatter.double(from: viewModel.amount), amount != 0.00 else { return }
        
        viewModel.tip.amount = amount
        viewModel.tip.comment = viewModel.comment
        
        dismiss()
    }
}

extension EditTipView {
    class ViewModel: ObservableObject {
        @AppStorage("appTint", store: .init(suiteName: "group.com.fromderik.Gratuity")) var appTint: Color = .blue
        @Published var amount : String
        @Published var comment = ""
        @Published var tip: Tip
        
        init(tip: Tip) {
            self.tip = tip
            self.amount = NumberFormatter.currencyString(from: tip.amount) ?? "0".currencyInputFormatting()
        }
    }
}

struct EditTipView_Previews: PreviewProvider {
    static var previews: some View {
        EditTipView(tip: Tip(context: DataManager.main.context))
    }
}
