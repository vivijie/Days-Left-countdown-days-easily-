//
//  BigDaysTableViewController.swift
//  DaysLeft
//
//  Created by viviJIE on 8/27/17.
//  Copyright © 2017 tdones. All rights reserved.
//

import UIKit
import CoreData

class BigDaysTableViewController: UITableViewController, AddBigDayViewControllerDelegate {

    
    var bigdays: [BigDay] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Days"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BigDay")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<BigDay> = BigDay.fetchRequest()
        
        // Sorting
//        let sortDescriptor = NSSortDescriptor(key: BigDay.title, ascending: true)
//        
//        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            bigdays = try managedContext.fetch(fetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    func addBigDayViewControllerDidCancel(controller: AddBigDayViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Add Row
    func addBigDayViewController(controller: AddBigDayViewController, title: String, date: Date, repeat_type: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let day = BigDay(entity: BigDay.entity(), insertInto: managedContext)
        
        day.title = title
        day.big_date = date
        day.repeat_type = repeat_type
        
        do {
            try managedContext.save()
            bigdays.append(day)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    // Edit Row
    func addBigDayViewController(controller: AddBigDayViewController, didFinishEditingItem item: BigDay) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        print("Edited: \(item)")
        
        self.tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bigdays.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    
        let day = bigdays[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BigDayOne", for: indexPath)
        
        if let bigdayTableViewCell = cell as? BigDayTableViewCell {
            bigdayTableViewCell.bigday = day
        }
        return cell
    }
    
    // Delete Row
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let dayToDelete = bigdays[indexPath.row]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        print(bigdays.count)
        print(dayToDelete)
        
        managedContext.delete(dayToDelete)
        bigdays.remove(at: indexPath.row)
        
        do {
            try managedContext.save()
            print(bigdays.count)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error as NSError {
            print("Saving error: \(error), description: \(error.userInfo)")
        }
    }
    
    
    // Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddBigDay" {
            let navigationController = segue.destination as! UINavigationController
            
            let controller = navigationController.topViewController as! AddBigDayViewController
            
            controller.delegate = self
        } else if segue.identifier == "EditBigDay" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! AddBigDayViewController
            controller.delegate = self
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.itemToEdit = bigdays[indexPath.row] 
            }
        }
    }
}
