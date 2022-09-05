//
//  GratuityWidget.swift
//  GratuityWidget
//
//  Created by Derik Malcolm on 9/1/2022.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

import WidgetKit
import SwiftUI
import GratuityShared

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> TodayTotalEntry {
        TodayTotalEntry(date: Date(), size: context.displaySize, tips: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayTotalEntry) -> ()) {
        let entry = TodayTotalEntry(date: Date(), size: context.displaySize, tips: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let tomorrow = Date().addingTimeInterval(86400)
        let refreshAfter = Calendar.current.startOfDay(for: tomorrow)
        
        let request = Tip.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true), NSSortDescriptor(key: "createdAt", ascending: true)]
        request.predicate = NSPredicate(format: "date >= %@", Calendar.current.startOfDay(for: Date()) as CVarArg)
        
        do {
            let tips = try DataManager.main.context.fetch(request)
            let entry = TodayTotalEntry(date: .now, size: context.displaySize, tips: tips)
            let timeline = Timeline(entries: [entry], policy: .after(refreshAfter))
            completion(timeline)
        } catch {
            fatalError("Error fetching the request")
        }
    }
}

struct TodayTotalEntry: TimelineEntry {
    let date: Date
    let size: CGSize
    let tips: [Tip]
}

struct TodaysTotalEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: TodayTotalEntry
    var arraySlice : ArraySlice<Tip> {
        entry.tips.suffix(5)
    }
    
    var lastFive: [Tip] {
        Array(arraySlice)
    }

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color("AppTint").gradient)
            
            switch widgetFamily {
            case .systemSmall:
                smallWidget
            case .systemMedium:
                mediumWidget
            default:
                EmptyView()
            }
        }
    }
    
    var smallWidget: some View {
        VStack {
            HStack {
                Text("Today")
                Text("\(entry.tips.count) tips")
            }
            .font(.caption)
            
            Spacer()
            
            Text(NumberFormatter.currencyString(from: entry.tips.total()) ?? "")
                .font(.largeTitle.bold())
                .minimumScaleFactor(0.6)
                .lineLimit(1)
//                .shadow(radius: 5)
            Spacer()
        }
        .foregroundColor(.white)
        .padding()
    }
    
    var mediumWidget: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                smallWidget
                    .frame(width: proxy.size.width / 2)
                
                Divider()
                
                VStack(spacing: 0) {
                    ForEach(0..<5) { int in
                        if let tip = lastFive[safe: int] {
                            VStack {
                                Divider().opacity(0)
                                
                                HStack {
                                    Text(NumberFormatter.currencyString(from: tip.amount) ?? "")
                                    Spacer()
                                    Text(tip.createdAt ?? .now, style: .time)
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                                .font(.caption)
                                .padding(.horizontal)
                                
                                Divider()
                            }
                            .frame(maxHeight: .infinity)
                        } else {
                            VStack {
                                Divider().opacity(0)
                                Text("Empty").font(.caption).opacity(0)
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 2)
            }
            .frame(height: proxy.size.height)
        }
    }
}

struct TodaysTotalWidget: Widget {
    let kind: String = "TodaysTotalWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodaysTotalEntryView(entry: entry)
        }
        .configurationDisplayName("Todays Total")
        .description("Shows the total amount made today.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular])
    }
}

struct TodaysTotalWidgetWidget_Previews: PreviewProvider {
    @Environment(\.widgetFamily) static var family
    
    static var previews: some View {
        Group {
            TodaysTotalEntryView(entry: TodayTotalEntry(date: Date(), size: .zero, tips: []))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small")
            
            TodaysTotalEntryView(entry: TodayTotalEntry(date: Date(), size: .zero, tips: []))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium")
        }
    }
}
