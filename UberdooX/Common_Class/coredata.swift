//
//  coredata.swift
//  core
//
//  Created by admin on 9/3/18.
//  Copyright © 2018 admin. All rights reserved.
//

import UIKit
import CoreData

class coredb {
    func coredata() -> NSManagedObjectContext {
         let appdelegate = UIApplication.shared.delegate as! AppDelegate
        return appdelegate.persistentContainer.viewContext
    }
    func insertValues (dict : NSDictionary){
        let managedContext = coredata()
        let entity = NSEntityDescription.entity(forEntityName: "Banner", in: managedContext)
        
        let Feed = NSManagedObject(entity: entity!, insertInto: managedContext)
        print("dictionary = \(dict)")
        let name = dict.value(forKey: "name")
        let id = dict.value(forKey: "id")
        let image = dict.value(forKey: "icon")
        let category = dict.value(forKey: "Category")
        let subcat_id = dict.value(forKey: "sub_Cat_id")
        let cat_id = dict.value(forKey: "cat_id")
        Feed.setValue(name, forKey: "name")
        Feed.setValue(id, forKey: "id")
        Feed.setValue(image, forKey: "icon")
        Feed.setValue(category, forKey: "category")
        Feed.setValue(subcat_id, forKey: "subcat_id")
        Feed.setValue(cat_id, forKey: "cat_id")
        do {
            try managedContext.save()
        } catch let error as NSError
        {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetch() ->[NSManagedObject] {
        let managedObjectContext = coredata()
        let entity = NSFetchRequest<NSManagedObject>.init(entityName: "Banner")
        var Feed = [NSManagedObject]()
        
        do {
          Feed = try managedObjectContext.fetch(entity)
            
        } catch let error as NSError {
            print("Could not save . \(error), \(error.userInfo)")
        }
        
        return Feed
    }
    func Updatedata(id : Int , name: String, image: String)
    {
    let managedContext = coredata()
        let fetchrequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Banner")
        
        fetchrequest.predicate = NSPredicate(format: "id", id)
        do {
            
        }
        
    }
    func deleteProfile(withID: Int) {
//
////        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = coredb().fetch()
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Banner")
//        fetchRequest.predicate = NSPredicate.init(format: "profileID==\(withID)")
//        let object = try! connect.fetch(fetchRequest)
//        connect.delete(object)
    }
    
    func removeBanner(Favid:Int)
    {
        let context:NSManagedObjectContext = self.coredata()
        let deleteRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Banner")
        deleteRequest.predicate = NSPredicate(format: "cat_id = %d", Favid)
        do {
            let fetchResults = try context.fetch(deleteRequest) as? [NSManagedObject]
            if (fetchResults?.count)!>0//update
            {
                context.delete((fetchResults?[0])!)
            }
            do
            {
                try context.save()
                print("Deleted! data particular data")
            } catch let error as NSError  {
                print("Could not delete \(error), \(error.userInfo)")
            } catch {}
        }
        catch let error as NSError
        {
            print(error)
        }
    }
    func removeBannersub(Favid:Int)
    {
        let context:NSManagedObjectContext = self.coredata()
        let deleteRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Banner")
        deleteRequest.predicate = NSPredicate(format: "subcat_id = %d", Favid)
        do {
            let fetchResults = try context.fetch(deleteRequest) as? [NSManagedObject]
            if (fetchResults?.count)!>0//update
            {
                context.delete((fetchResults?[0])!)
            }
            do
            {
                try context.save()
                print("Deleted! data particular data")
            } catch let error as NSError  {
                print("Could not delete \(error), \(error.userInfo)")
            } catch {}
        }
        catch let error as NSError
        {
            print(error)
        }
    }
}

