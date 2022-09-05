//
//  Extensions.swift
//  Tipped
//
//  Created by Derik Malcolm on 9/1/2022.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

import Foundation
import SwiftUI

public extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U : [Iterator.Element]] {
        return Dictionary(grouping: self, by: key)
    }
}

public extension Collection<Tip> {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    func total() -> Double {
        return self.reduce(0, {$0 + $1.amount})
    }
}

public extension Date {
    func relativeDateFormatted() -> String {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        return formatter.string(from: self)
    }
}

public extension NumberFormatter {
    static func currencyString(from double: Double) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .currency
//        numberFormatter.currencyCode = Locale.current.currencyCode
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        guard let total = numberFormatter.string(from: double as NSNumber) else { return nil }
        
        return total
    }
    
    static func double(from currencyString: String) -> Double? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .currency
//        numberFormatter.currencyCode = Locale.current.currencyCode
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        
        guard let number = numberFormatter.number(from: currencyString) else { return nil }
        return number.doubleValue
    }
}

public extension String {
    func currencyInputFormatting() -> String {
        var number: NSNumber
        
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        
        let amountWithPrefix = regex.stringByReplacingMatches(in: self, options: .init(rawValue: 0), range: .init(location: 0, length: self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        return NumberFormatter.currencyString(from: number.doubleValue)!
    }
    
    func removingCurrency() -> String {
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        let amountWithoutPrefix = regex.stringByReplacingMatches(in: self, options: .init(rawValue: 0), range: .init(location: 0, length: self.count), withTemplate: "")
        
        return amountWithoutPrefix
    }
}

public extension Calendar {
    func week(for date: Date) -> [Date] {
        var components = dateComponents([.weekday, .day, .month, .year], from: date)
        guard let weekday = components.weekday else { return [] }
        guard let day = components.day else { return [] }
        
        if weekday == 1 {
            components.day = (day - (weekday - 2)) - 7
        } else {
            components.day = day - (weekday - 2)
        }
        
        guard let startDate = self.date(from: components) else { return [] }
        
        var dates = [startDate]
        
        for _ in 1 ... 6 {
            guard let day = components.day else { return [] }
            components.day = day + 1
            
            guard let date = self.date(from: components) else { return [] }
            
            dates.append(date)
        }
        
        return dates
    }
    
    func month(for date: Date) -> [Date] {
        var components = dateComponents([.day, .month, .year], from: date)
        guard let month = components.month else { return [] }
        
        components.day = 1
        
        guard let startDate = self.date(from: components) else { return [] }
        
        var dates = [startDate]
        
        for _ in 0 ... 31 {
            components.day! += 1
            
            guard let date = self.date(from: components) else { return [] }
            
            let monthCom = self.component(.month, from: date)
            
            if monthCom == month {
                dates.append(date)
            }
        }
        
        return dates
    }
}

extension Color: RawRepresentable {

    public init?(rawValue: String) {
        
        guard let data = Data(base64Encoded: rawValue) else {
            self = .accentColor
            return
        }
        
        do {
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .black
            self = Color(color)
        } catch {
            self = .accentColor
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }

}
