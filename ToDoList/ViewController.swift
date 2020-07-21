//
//  ViewController.swift
//  ToDoList
//
//  Created by WooL on 2019/7/2.
//  Copyright © 2019年 ＷooL. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var myConstraintY: NSLayoutConstraint!
    @IBOutlet weak var doAddandEdit: UIButton!
    
    let realm = try! Realm()
    let controllDataBase = ControllDataBase()
    let dateFormatter = DateFormatter()
    var isEditMod = false
    var nowIndexPath = 0
    var searchDisplay: [(String, Date)] = []
    var searchString = ""
    
    @IBAction func addTask(_ sender: Any) {
        if taskTextField.text == "" {
            showAlert()
        } else {
            if isEditMod == false {
                controllDataBase.addData(taskTextField.text!)
            } else {
                if navigationItem.searchController!.isActive {
                    controllDataBase.searchPlusEdit(searchString, taskTextField.text!,     nowIndexPath)
                    searchDisplay = controllDataBase.searchData(searchString)
                } else {
                    controllDataBase.editData(taskTextField.text!, nowIndexPath)
                }
                nowIndexPath = 0
                isEditMod = false
                doAddandEdit.setTitle("enter", for: .normal)
            }
            listTableView.reloadData()
            taskTextField.text = ""
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(ViewController.keyboardWillChange(_:)),
        name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        super.navigationController?.navigationBar.prefersLargeTitles = true
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        listTableView.dataSource = self
        listTableView.delegate = self
        
        listTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        print("fileURL: \(realm.configuration.fileURL!)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        listTableView.setEditing(editing, animated: true)
    }
    //MARK: - 移動鍵盤
    @objc func keyboardWillChange (_ notification: Notification){
        if let userInfo = notification.userInfo,
            let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
             
            let frame = value.cgRectValue
            let intersection = frame.intersection(self.view.frame)
             
            //self.view.setNeedsLayout()
            //改變下約束
            self.myConstraintY.constant = -intersection.height
             
            UIView.animate(withDuration: duration, delay: 0.0,
                           options: UIView.AnimationOptions(rawValue: curve), animations: {
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    // MARK: - Show alert function
    func showAlert() {
        let alertController = UIAlertController(title: "錯誤", message: "尚未輸入內容", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    // MARK: - Tableview data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tasks = realm.objects(Task.self)
        if navigationItem.searchController!.isActive {
            return searchDisplay.count
        } else {
            return tasks.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        if navigationItem.searchController!.isActive {
            let task = searchDisplay[indexPath.row].0
            let date = searchDisplay[indexPath.row].1
            let dateString = dateFormatter.string(from: date)
            cell.textLabel?.text = task + " @ " + dateString
        } else {
            let dateString = dateFormatter.string(from: task[indexPath.row].date)
            cell.textLabel?.text = controllDataBase.getData(indexPath.row) + " @ " + dateString
        }
        
        return cell
    }
    //實作TableView方法，自動出現左滑功能  編輯 ＆ 刪除
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 刪除
        let deleteItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            self.controllDataBase.deleteData(indexPath.row)
            tableView.reloadData()
        }
        // 編輯
        let editItem = UIContextualAction(style: .normal, title: "Edit") {  (contextualAction, view, boolValue) in
            self.nowIndexPath = indexPath.row
            if self.navigationItem.searchController!.isActive {
                self.taskTextField.text = self.searchDisplay[self.nowIndexPath].0
            } else {
                self.taskTextField.text = self.controllDataBase.getData(self.nowIndexPath)
            }
            self.doAddandEdit.setTitle("edit", for: .normal)
            self.isEditMod = true
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])
        return swipeActions
    }
    
    //MARK: - Search Bar
   func updateSearchResults(for searchController: UISearchController) {
    searchString = searchController.searchBar.text!
    searchDisplay = controllDataBase.searchData(searchString)
    listTableView.reloadData()
    }
}
