//
//  CategoryTableViewController.swift
//  TaskManager
//
//  Created by Süleyman Koçak on 17.03.2020.
//  Copyright © 2020 Suleyman Kocak. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {

    var categories = [Category]()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font:UIFont.systemFont(ofSize: 23)]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }








    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        makeAlert(title: "Add New Category", message: "")
    }

    func makeAlert(title:String,message:String){
        var textField = UITextField()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let addButton = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categories.append(newCategory)
            self.saveCategory()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addTextField { (alertTextField) in
            textField.placeholder = "Add New Task"
            textField = alertTextField
        }
        alert.addAction(addButton)
        alert.addAction(cancelButton)
        present(alert,animated: true,completion: nil)
    }
    func saveCategory(){
        do {
            try self.context.save()
        } catch  {
            print(error)
        }
        self.tableView.reloadData()
    }

    func loadCategories(with request:NSFetchRequest<Category> = Category.fetchRequest(),predicate:NSPredicate?=nil){
        if let predicate = predicate{
            request.predicate = predicate
        }
        do {
            self.categories = try context.fetch(request)
        } catch{
            print(error)
        }
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TaskManagerController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
}

extension CategoryTableViewController{
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTasks", sender: self)
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.context.delete(categories[indexPath.row])
            self.saveCategory()
            categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }



}
extension CategoryTableViewController:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadCategories()
            searchBar.resignFirstResponder()
        }else{
            let request : NSFetchRequest<Category> = Category.fetchRequest()
            let predicate = NSPredicate(format: "name CONTAINS %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

            loadCategories(with: request,predicate: predicate)
        }

    }


}
