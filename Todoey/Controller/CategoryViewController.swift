//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Vsevolod on 23.11.2020.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {


    
    
    let realm = try! Realm()
    
    var catArrey: Results<Category>?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        loadCategory()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        
        
        
        
        let mainColour = UIColor(hexString: "1D9BF6")
        let contrastColour = ContrastColorOf(mainColour!, returnFlat: true)
        
        
        navBar.backgroundColor = mainColour
        navBar.barTintColor = mainColour
        navBar.tintColor = contrastColour
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : contrastColour]
        
        
        tableView.backgroundColor = mainColour
        
    }
    
     
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = catArrey?[indexPath.row]
        }
    }
    
    
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catArrey?.count ?? 1
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = catArrey?[indexPath.row].name ?? "No Categories added yet"
        cell.backgroundColor = UIColor.init(hexString: (catArrey?[indexPath.row].colour)!) ?? nil
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor ?? UIColor.black, returnFlat: true)

        return cell
    }

    
    //MARK: - TableView Add Methods
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCat = Category()
            newCat.name = textField.text!
            newCat.colour = UIColor.randomFlat().hexValue()
            
            self.save(category: newCat)

        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
//
    }


    

    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category){
        
        do{
            try realm.write(){
                realm.add(category)
            }
        }catch{
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategory(){
        
        catArrey = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.catArrey?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(item)
                    //                    self.tableView.deleteRows(at: item, with: UITableView.RowAnimation)
                }
            }catch{  print("Error delete status, \(error)")
            }
        }
    }


}

// MARK: - Swipe Cell Delegate Method
