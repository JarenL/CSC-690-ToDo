//
//  ViewController.swift
//  ToDo
//
//  Created by Jaren Lynch on 5/15/19.
//  Copyright © 2019 Jaren Lynch. All rights reserved.
//

import UIKit

class TaskTableViewController: UITableViewController {

    var taskList: [Task] = []
    
    @IBAction func addTaskButton(_ sender: Any) {
        let newTaskAlert = UIAlertController(title: "New To-Do Task",
                                             message: "Describe your task!",
                                             preferredStyle: .alert)
        newTaskAlert.addTextField(configurationHandler: nil)
        newTaskAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil)) //cancel
        newTaskAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in //add
            if let title = newTaskAlert.textFields?[0].text {
                self.addNewTask(title: title)
            }
        }))
        self.present(newTaskAlert, animated: true, completion: nil)
    }
    
    private func addNewTask(title: String)
    {
        let bottomOfList = taskList.count
        taskList.append(Task(title))
        tableView.insertRows(at: [IndexPath(row: bottomOfList, section: 0)], with: .top)
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int
    {
        return taskList.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = taskList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell")!
        cell.textLabel?.text = item.title
        let taskCheckmark: UITableViewCell.AccessoryType = item.done ? .checkmark : .none
        cell.accessoryType = taskCheckmark
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = taskList[indexPath.row]
        item.done = !item.done
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath)
    {
        taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .top)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "To-Do"
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appMovedToBackground),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
        if let listLength: Int = UserDefaults.standard.object(forKey: "listLength") as? Int{
            let decoder = JSONDecoder()
            
            for i in 0..<listLength{
                var key = String(i)
                if let dataFromStorage = UserDefaults.standard.object(forKey: key) as? Data{
                    let personFromStorage = try! decoder.decode(Task.self, from: dataFromStorage)
                    taskList.append(personFromStorage)
                }
            }
        }
    }
    
    @objc func appMovedToBackground() {
        UserDefaults.standard.set(taskList.count, forKey: "listLength")
        
        let encoder = JSONEncoder()
        for i in 0..<taskList.count{
            var encoded = try! encoder.encode(taskList[i])
            var jsonString = String(data: encoded, encoding: .utf8)
            var key = String(i)
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

