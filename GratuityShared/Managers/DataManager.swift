//
//  DataManager.swift
//  Gratuity
//
//  Created by Derik Malcolm on 9/1/2022.
//  Copyright © 2022 Derik Malcolm. All rights reserved.
//

import CoreData
import CloudKit
import WidgetKit

fileprivate class CustomPersistentContainer: NSPersistentCloudKitContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.fromderik.Gratuity")?.appendingPathComponent("Tipped")
        guard let url = storeURL else {
            print("No Persistence Storage file found")
            return super.defaultDirectoryURL()
        }
        return url
    }
}

public class DataManager: ObservableObject {
    
    public static var preview: DataManager = {
        let result = DataManager(inMemory: true)
        let viewContext = result.persistentContainer.viewContext
        for i in 0..<24 {
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: .now)
            
            let tip = Tip(context: viewContext)
            tip.amount = Double.random(in: 5...15)
            tip.comment = ""
            tip.date = Calendar.current.date(from: dateComponents)
            tip.createdAt = Calendar.current.date(bySetting: .hour, value: i, of: .now)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    public var context: NSManagedObjectContext {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    private var persistentContainer: NSPersistentCloudKitContainer = {
        let container = CustomPersistentContainer(name: "Tipped")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            storeDescription.shouldInferMappingModelAutomatically = true
            storeDescription.shouldMigrateStoreAutomatically = true
        }
        return container
    }()
    
    public static var main = DataManager()

    private init() {}
    
    public init(inMemory: Bool = false) {
        persistentContainer = CustomPersistentContainer(name: "Tipped")
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Core Data Saving support
    
    public func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                WidgetCenter.shared.reloadAllTimelines()
            } catch let error as NSError {
                print("Failed to save context")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    public func addTip(amount: Double, comment: String = "", date: Date, completion: @escaping (Tip) -> Void) {
        let tip = Tip(context: context)
        tip.amount = amount
        tip.comment = comment
        tip.date = date
        tip.createdAt = Date()
        
        saveContext()
        completion(tip)
    }
    
    public func delete(_ tip: Tip) {
        context.delete(tip)
        
        saveContext()
    }
    
    //MARK: - Core Data Fetching
    
    public func fetchTips(dates: [Date] = [Date](), completionHandler: @escaping ([Tip]) -> Void) throws {
        let request: NSFetchRequest<Tip> = Tip.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true), NSSortDescriptor(key: "createdAt", ascending: true)]
        
        if dates.count > 0 {
            request.predicate = NSPredicate(format: "date in %@", dates)
        }
        
        do {
            let tips = try context.fetch(request)
            completionHandler(tips)
        } catch let error {
            throw error
        }
    }
    
    public func fetchTipsBetweenDates(_ dates: (startDate: Date, endDate: Date), completionHandler: @escaping ([Tip]) -> Void) throws {
        let request: NSFetchRequest<Tip> = Tip.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true), NSSortDescriptor(key: "createdAt", ascending: true)]
        
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [dates.startDate, dates.endDate])
        
        do {
            let tips = try context.fetch(request)
            completionHandler(tips)
        } catch let error {
            throw error
        }
    }
}
