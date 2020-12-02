//
//  ViewController.swift
//  Todoey
//
//  Created by Vsevolod on 20.11.2020.
//

import UIKit
import RealmSwift
import ChameleonFramework


class TodoListViewController: SwipeTableViewController {
    
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory,
//                                                in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 60.0
        tableView.separatorStyle = .none
        

    }
    override func viewWillAppear(_ animated: Bool){
        title = selectedCategory?.name
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        
        if let colourHex = selectedCategory?.colour{
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
            print(colourHex)
            let mainColour = UIColor(hexString: colourHex)
            let contrastColour = ContrastColorOf(navBar.backgroundColor!, returnFlat: true)
            
            
            navBar.backgroundColor = mainColour
            navBar.barTintColor = mainColour
            navBar.tintColor = contrastColour
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : contrastColour]

            searchBar.barTintColor = mainColour
            searchBar.backgroundImage = UIImage()
            searchBar.backgroundColor = mainColour
            searchBar.tintColor = contrastColour
            textFieldInsideSearchBar?.textColor = contrastColour
            
            
            tableView.backgroundColor = mainColour
            
        }

    }
  
    
    //MARK: - Tableview Datasourse Methods
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = todoItems?[indexPath.row].title
            
            /// Set cell colour
            if let colour = UIColor.init(hexString: selectedCategory?.colour ?? "#FFFFFF")!.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(todoItems!.count)){

                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                cell.tintColor = ContrastColorOf(colour, returnFlat: true)
                
            }
            cell.accessoryType = item.done  ? .checkmark : .none
            
        }else{
            cell.textLabel?.text = "No Items Added"
        }
        
        
        
        return cell
    }
    
    
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    
                    item.done = !item.done
                }
                
            }catch{
                print("Error saving done status, \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        self.tableView.reloadData()
    }
    
    
    //MARK: - Add New Items Methods
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            
            
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                        
                    }
                }catch{
                    print("Error saving context \(error)")
                }
                
            }
            
            
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //MARK: - Model Manipulation Methods
    
    
//    func save() {
//
//                do{
//                    try realm.write(){
//                        realm.add(item,checkmark)
//                    }
//                } catch {
//                    print("Error saving context \(error)")
//                }
//                self.tableView.reloadData()
//    }
    
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        todoItems = selectedCategory?.items.sorted(byKeyPath: "done", ascending: true)
        
        self.tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(item)
                    
                }
            }catch{  print("Error delete status, \(error)")
            }
        }
    }
    
    
}

//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!)
            .sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
