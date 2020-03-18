//
//  ViewController.swift
//  TaskManager
//
//  Created by Süleyman Koçak on 16.03.2020.
//  Copyright © 2020 Suleyman Kocak. All rights reserved.
//

import UIKit
import CoreData
class TaskManagerController: UITableViewController{
    var taskArray = [Task]()
    var selectedCategory : Category? {
        didSet{
            loadTasks()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 23)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes

        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        cell.textLabel?.text = taskArray[indexPath.row].title

        if taskArray[indexPath.row].done == true {
            cell.accessoryType = .checkmark

        }else{
            cell.accessoryType = .none

        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        taskArray[indexPath.row].done = !taskArray[indexPath.row].done
        tableView.cellForRow(at: indexPath)?.accessoryType = taskArray[indexPath.row].done ? .checkmark : .none
        //        context.delete(taskArray[indexPath.row])
        //        taskArray.remove(at: indexPath.row)


        saveTask()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.context.delete(taskArray[indexPath.row])
            self.saveTask()
            taskArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }



    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        makeAlert(title: "Add New Task", message: "")
    }

    //MARK: - Alert Function
    func makeAlert(title:String,message:String){
        var textField = UITextField()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let addButton = UIAlertAction(title: "Add", style: .default) { (action) in
            let newTask = Task(context: self.context)
            newTask.title = textField.text!
            newTask.done = false
            newTask.parentCategory = self.selectedCategory
            self.taskArray.append(newTask)
            self.saveTask()
            self.tableView.reloadData()

        }
        alert.addTextField { (alertTextField) in
            textField.placeholder = "Add New Task"
            textField = alertTextField
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alert.addAction(addButton)
        alert.addAction(cancelButton)
        present(alert,animated: true,completion: nil)
    }

    

    func saveTask(){
        do {
            try self.context.save()
        } catch{
            print(error)
        }
        self.tableView.reloadData()
    }


    func loadTasks(with request: NSFetchRequest<Task> = Task.fetchRequest(),predicate:NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        do {
            self.taskArray = try self.context.fetch(request)
        }catch{
            print(error)
        }
        tableView.reloadData()
    }






}

extension TaskManagerController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadTasks()
            searchBar.resignFirstResponder()
        }else{
            let request : NSFetchRequest<Task> = Task.fetchRequest()
            let predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

            loadTasks(with: request,predicate: predicate)
        }

    }


}



