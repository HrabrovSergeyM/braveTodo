//
//  CategoryViewController.swift
//  braveTodo
//
//  Created by Sergey Hrabrov on 14.03.2023.
//  Copyright © 2023 brave. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {
    
    var categoryArray = [Category]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    // MARK: - Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name ?? "No Categories Added Yet"
//        if indexPath.row == 0 {
//            cell.backgroundColor = UIColor(named: "firstCategory")
//        } else {
            cell.backgroundColor = UIColor(hexString: categoryArray[indexPath.row].color ?? "1D9BF6")
//        }
        cell.textLabel?.textColor = ContrastColorOf( UIColor(hexString: categoryArray[indexPath.row].color ?? "1D9BF6")!, returnFlat: true)
        
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
        saveCategories()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    
    @IBAction func addCategoryPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text ?? "New category"
            newCategory.color = UIColor.randomFlat().hexValue()
            
            
            self.categoryArray.append(newCategory)
            
            self.saveCategories()
            
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // MARK: - Model Manipulation Methods
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error reading context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        self.context.delete(categoryArray[indexPath.row])
        categoryArray.remove(at: indexPath.row)
    }
}


