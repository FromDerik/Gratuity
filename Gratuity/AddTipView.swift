//
//  AddTipView.swift
//  Gratuity
//
//  Created by Derik Malcolm on 9/1/2022.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

// AEE5081A-F449-4365-8632-376AB6FEE6D3

import SwiftUI
import GratuityShared

struct AddTipView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: ViewModel
    
    init(date: Binding<Date>) {
        self.viewModel = ViewModel(date: date)
    }
    
    var body: some View {
        let binding = Binding<String>(get: {
            self.viewModel.amount
        }, set: {
            self.viewModel.amount = $0.currencyInputFormatting()
        })
        
        return NavigationView {
            ZStack(alignment: .bottom) {
                Form {
                    Section {
                        TextField("Amount", text: binding)
                            .keyboardType(.numberPad)
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
                        .fill(Color("AppTint")
                            .gradient
                        )
                    )
                    .foregroundColor(Color(uiColor: .systemBackground))
                    .padding()
                }
            }
        }
    }
    
    func save() {
        guard let amount = NumberFormatter.double(from: viewModel.amount) else { return }
        
#if targetEnvironment(simulator)
        let dataManager = DataManager.preview
#else
        let dataManager = DataManager.main
#endif
        
        dataManager.addTip(amount: amount, comment: viewModel.comment, date: viewModel.date) { _ in
            self.dismiss()
        }
    }
}

extension AddTipView {
    class ViewModel: ObservableObject {
        @Published var amount = "0".currencyInputFormatting()
        @Published var comment = ""
        var date: Date
        
        init(date: Binding<Date>) {
            self.date = date.wrappedValue
        }
    }
}

struct AddTipView_Previews: PreviewProvider {
    static var previews: some View {
        AddTipView(date: .constant(Date()))
    }
}