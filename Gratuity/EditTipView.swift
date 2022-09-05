//
//  EditTipView.swift
//  Gratuity
//
//  Created by Derik Malcolm on 9/1/2022.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

import SwiftUI

import GratuityShared

struct EditTipView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var persistenceController: DataManager
    @State private var amount = "0".currencyInputFormatting()
    @State private var comment = ""
    @Binding var tip: Tip?
    
    var body: some View {
        let binding = Binding<String>(get: {
            self.amount
        }, set: {
            self.amount = $0.currencyInputFormatting()
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
                        TextField("Comment", text: $comment)
                    } header: {
                        Text("Comment")
                    }
                    
                }
                .navigationTitle("Edit Tip")
                
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
                            .shadow(.inner(radius: 5))
                        )
                    )
                    .foregroundColor(Color(uiColor: .systemBackground))
                    .padding()
                }
            }
        }
    }
    
    func save() {
        guard let amount = NumberFormatter.double(from: amount) else { return }
        guard let tip = tip else { return }
        
        tip.amount = amount
        tip.comment = comment
        
        persistenceController.saveContext()
    }
}

struct EditTipView_Previews: PreviewProvider {
    static var persistence = DataManager.preview
    static var previews: some View {
        EditTipView(tip: .constant(Tip(context: persistence.context)))
    }
}
