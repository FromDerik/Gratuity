//
//  MainView.swift
//  Gratuity
//
//  Created by Derik Malcolm on 9/1/2022.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

import SwiftUI
import Charts
import GratuityShared

struct MainView: View {
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            if !viewModel.searchText.isEmpty {
                listView
            } else {
                ZStack(alignment: .bottomTrailing) {
                    VStack(spacing: 16) {
                        Picker("", selection: $viewModel.pickerSelection) {
                            ForEach(PickerValues.allCases, id: \.self) { value in
                                Text(value.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .onChange(of: viewModel.pickerSelection) { _ in viewModel.fetchData() }
                        
                        datePicker
                            .onChange(of: viewModel.selectedDate) { _ in viewModel.fetchData() }
                            .padding(.horizontal)
                        
                        if viewModel.showingChart {
                            Chart(viewModel.chartData) { data in
                                BarMark(
                                    x: .value("Hour", data.date, unit: data.unit),
                                    y: .value("Amount", data.amount)
                                )
                            }
                            .foregroundStyle(viewModel.appTint)
                            .chartYAxisLabel { chartYAxisLabel }
                            .frame(height: 150)
                            .padding(.horizontal)
                        }
                        
                        listView
                    }
                    .navigationTitle(NumberFormatter.currencyString(from: viewModel.total) ?? "Home")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                viewModel.showingSettingsView.toggle()
                            } label: {
                                Image(systemName: "gearshape.fill")
                            }
                            
                        }
                    }
                    .toolbarTitleMenu {
                        Text("Hi")
                        Text("Hello")
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText)
        // Add Tip View
        .sheet(isPresented: $viewModel.showingAddTipView, onDismiss: {
            viewModel.fetchData()
        }, content: {
            AddTipView(date: viewModel.selectedDate)
                .environmentObject(viewModel.dataManager)
                .presentationDetents([.medium])
        })
        // Edit Tip View
        .sheet(item: $viewModel.tipToEdit, onDismiss: {
            viewModel.tipToEdit = nil
            viewModel.fetchData()
        }, content: { tip in
            EditTipView(tip: tip)
                .environmentObject(viewModel.dataManager)
                .presentationDetents([.medium])
        })
        // Settings View
        .sheet(isPresented: $viewModel.showingSettingsView) {
            SettingsView()
                .presentationDetents([.large, .medium])
        }
        .tint(viewModel.appTint)
    }
    
    @ViewBuilder
    var listView: some View {
        List(viewModel.searchResults) { day in
            Section {
                ForEach(day.tips.sorted { $0.createdAt! < $1.createdAt! }) { tip in
                    VStack(alignment: .leading) {
                        Text(NumberFormatter.currencyString(from: tip.amount) ?? "")
                        HStack(spacing: 0) {
                            Text(tip.createdAt?.formatted(date: .omitted, time: .shortened) ?? "")
                            if !tip.comment!.isEmpty {
                                Text(" • ") + Text(tip.comment!)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                        Button {
                            viewModel.delete(tip)
                        } label: {
                            Label {
                                Text("Delete")
                            } icon: {
                                Image(systemName: "trash")
                            }
                        }
                        .tint(Color.red)
                        
                        Button {
                            viewModel.tipToEdit = tip
                        } label: {
                            Label {
                                Text("Edit")
                            } icon: {
                                Image(systemName: "pencil")
                            }
                        }
                        .tint(Color.orange)
                    })
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            viewModel.dataManager.addTip(amount: tip.amount, date: tip.date!) { _ in
                                viewModel.fetchData()
                            }
                        } label: {
                            Label {
                                Text("Add")
                            } icon: {
                                Image(systemName: "plus")
                            }
                        }
                        .tint(viewModel.appTint)
                    }
                }
            } header: {
                HStack {
                    Text(day.date.relativeDateFormatted())
                    Spacer()
                    Text(NumberFormatter.currencyString(from: day.tips.total()) ?? "")
                        .font(Font.body.bold())
                    Spacer()
                    Text("\(day.tips.count) tips")
                }
                .frame(maxWidth: .infinity)
            }
        }
        
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
            Button {
                viewModel.showingAddTipView.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
            }
            .padding(.trailing)
        }
    }
    
    @ViewBuilder
    var datePicker: some View {
        ZStack {
            HStack {
                Button {
                    viewModel.showingChart.toggle()
                } label: {
                    Image(systemName: "chart.bar.fill")
                }
                .buttonStyle(CustomButtonStyle(pressed: viewModel.showingChart))
                
                Spacer()
                
                Button {
                    viewModel.showingDatePicker.toggle()
                } label: {
                    Image(systemName: "calendar")
                }
                .buttonStyle(CustomButtonStyle(pressed: viewModel.showingDatePicker))
            }
            
            HStack {
                Button {
                    switch viewModel.pickerSelection {
                    case .day:
                        self.viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.selectedDate)!
                    case .week:
                        self.viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -7, to: viewModel.selectedDate)!
                    case .month:
                        self.viewModel.selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: viewModel.selectedDate)!
                    case .year:
                        self.viewModel.selectedDate = Calendar.current.date(byAdding: .year, value: -1, to: viewModel.selectedDate)!
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                if viewModel.showingDatePicker {
                    DatePicker("", selection: $viewModel.selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .fixedSize()
                        .offset(x: -4)
//                        .accentColor(viewModel.appTint)
                } else {
                    Text(datePickerLabel)
                        .font(.body)
                        .padding(.horizontal)
                }
                
                Button {
                    switch viewModel.pickerSelection {
                    case .day:
                        self.viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate)!
                    case .week:
                        self.viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: viewModel.selectedDate)!
                    case .month:
                        self.viewModel.selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: viewModel.selectedDate)!
                    case .year:
                        self.viewModel.selectedDate = Calendar.current.date(byAdding: .year, value: 1, to: viewModel.selectedDate)!
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .font(.title2)
        .fontWeight(.semibold)
    }
    
    @ViewBuilder
    var chartYAxisLabel: some View {
        switch viewModel.pickerSelection {
        case .day:
            Text("\(Locale.current.currencySymbol ?? "$") / Hour")
        case .week, .month:
            Text("\(Locale.current.currencySymbol ?? "$") / Day")
        case .year:
            Text("\(Locale.current.currencySymbol ?? "$") / month")
        }
    }
    
    var datePickerLabel: String {
        let formatter = DateFormatter()
        
        switch viewModel.pickerSelection {
        case .day:
            formatter.dateStyle = .medium
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: viewModel.selectedDate)
        case .week:
            formatter.dateStyle = .short
            let dates = Calendar.current.week(for: viewModel.selectedDate)
            let first = dates.first!
            let last = dates.last!
            return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
        case .month:
            formatter.dateFormat = "LLL yyyy"
            return formatter.string(from: viewModel.selectedDate)
        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: viewModel.selectedDate)
        }
    }
}

extension MainView {
    class ViewModel: ObservableObject {
        @Published var selectedDate: Date
        
        @Published var searchText = ""
        
        @Published var days = [Day]()
        @Published var total: Double = 0
        @Published var chartData = [ChartData]()
        
        @Published var showingDatePicker = false
        @Published var showingAddTipView = false
        @Published var showingSettingsView = false
        
        @Published var tipToEdit: Tip?
        
        @AppStorage("pickerSelection") var pickerSelection: PickerValues = .day
        @AppStorage("showingChart") var showingChart = true
        @AppStorage("appTint", store: .init(suiteName: "group.com.fromderik.Gratuity")) var appTint: Color = .blue
        
#if targetEnvironment(simulator)
        let dataManager = DataManager.preview
#else
        let dataManager = DataManager.main
#endif
        
        var searchResults: [Day] {
            if searchText.isEmpty {
                return days
            } else {
                var searchDays = [Day]()
                do {
                    try dataManager.fetchTips(filter: searchText) { tips in
                        searchDays = tips
                            .group { $0.date! }
                            .compactMap { Day(tips: $0.value, date: $0.key) }
                            .sorted { $0.date < $1.date }
                    }
                } catch {
                    print(error)
                }
                return searchDays
            }
        }
        
        init() {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
            self.selectedDate = Calendar.current.date(from: components) ?? .now
            fetchData()
        }
        
        func fetchData() {
            switch pickerSelection {
            case .day:
                fetchDailyData()
            case .week:
                fetchWeeklyData()
            case .month:
                fetchMonthlyData()
            case .year:
                fetchYearlyData()
            }
        }
        
        func delete(_ tip: Tip) {
            dataManager.delete(tip)
            fetchData()
        }
        
        private func fetchDailyData() {
            do {
                try dataManager.fetchTips(dates: [selectedDate]) { tips in
                    self.total = tips.total()
                    self.days = tips
                        .group { $0.date! }
                        .compactMap { Day(tips: $0.value, date: $0.key) }
                        .sorted { $0.date < $1.date }
                    
                    var dict = [Date: [Tip]]()
                    for hour in (0..<24) {
                        let date = Calendar.current.date(bySetting: .hour, value: hour, of: self.selectedDate)
                        dict[date!] = [Tip]()
                    }
                    
                    self.chartData = tips
                        .group {
                            let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: $0.createdAt!)
                            let date = Calendar.current.date(from: components)!
                            return date
                        }
                        .merging(dict) { (current, _) in current }
                        .compactMap { ChartData(date: $0.key, amount: $0.value.total(), unit: .hour)}
                        .sorted { $0.date < $1.date }
                }
            } catch {
                print(error)
            }
        }
        
        private func fetchWeeklyData() {
            let dates = Calendar.current.week(for: selectedDate)
            
            do {
                try dataManager.fetchTips(dates: dates, completionHandler: { tips in
                    self.total = tips.total()
                    self.days = tips
                        .group { $0.date! }
                        .compactMap { Day(tips: $0.value, date: $0.key)}
                        .sorted { $0.date  < $1.date }
                    
                    var dict = [Date: [Tip]]()
                    dates.forEach { date in
                        dict[date] = [Tip]()
                    }
                    
                    self.chartData = tips
                        .group { $0.date! }
                        .merging(dict) { (current, _) in current }
                        .compactMap { ChartData(date: $0.key, amount: $0.value.total(), unit: .day) }
                        .sorted { $0.date < $1.date }
                })
            } catch {
                print(error)
            }
        }
        
        private func fetchMonthlyData() {
            let dates = Calendar.current.month(for: selectedDate)
            
            do {
                try dataManager.fetchTips(dates: dates, completionHandler: { tips in
                    self.total = tips.total()
                    self.days = tips
                        .group { $0.date! }
                        .compactMap { Day(tips: $0.value, date: $0.key)}
                        .sorted { $0.date  < $1.date }
                    
                    var dict = [Date: [Tip]]()
                    dates.forEach { date in
                        dict[date] = [Tip]()
                    }
                    
                    self.chartData = tips
                        .group { $0.date! }
                        .merging(dict) { (current, _) in current }
                        .compactMap { ChartData(date: $0.key, amount: $0.value.total(), unit: .day) }
                        .sorted { $0.date < $1.date }
                })
            } catch {
                print(error)
            }
        }
        
        private func fetchYearlyData() {
            let year = Calendar.current.component(.year, from: selectedDate)
            let startComponents = DateComponents(year: year, month: 1, day: 1, hour: 0, minute: 0, second: 0)
            let endComponents = DateComponents(year: year, month: 12, day: 31, hour: 23, minute: 59, second: 59)
            guard let startDate = Calendar.current.date(from: startComponents) else { return }
            guard let endDate = Calendar.current.date(from: endComponents) else { return }
            
            do {
                try dataManager.fetchTipsBetweenDates((startDate, endDate), completionHandler: { tips in
                    self.total = tips.total()
                    self.days = tips
                        .group { $0.date! }
                        .compactMap { Day(tips: $0.value, date: $0.key)}
                        .sorted { $0.date  < $1.date }
                    
                    var dict = [Date: [Tip]]()
                    (1..<13).forEach {
                        let date = Calendar.current.date(bySetting: .month, value: $0, of: startDate)!
                        dict[date] = [Tip]()
                    }
                    
                    self.chartData = tips
                        .group {
                            let components = Calendar.current.dateComponents([.year, .month], from: $0.date!)
                            let date = Calendar.current.date(from: components)!
                            return date
                        }
                        .merging(dict) { (current, _) in current }
                        .compactMap { ChartData(date: $0.key, amount: $0.value.total(), unit: .month) }
                        .sorted { $0.date < $1.date }
                })
            } catch {
                print(error)
            }
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
