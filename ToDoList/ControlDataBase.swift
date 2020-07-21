//
//  ControlDataBase.swift
//  ToDoList
//
//  Created by WooL on 2020/7/9.
//  Copyright © 2020 JeremyXue. All rights reserved.
//

import Foundation
import RealmSwift


class ControllDataBase {
    
    let realm = try! Realm()
    
    func searchData(_ taskName: String) -> [(String, Date)] {
        let foundTasks = realm.objects(Task.self).filter(String(format:"tasks CONTAINS[c] '%@'",taskName))
        var result: [(tasks:String, date:Date)] = []
        for foundTask in foundTasks {
            result.append((foundTask.tasks, foundTask.date))
        }
        return result
    }
    
    func searchPlusEdit(_ searchData: String, _ editData: String, _ findIndexPath: Int) {
        let foundTasks = realm.objects(Task.self).filter(String(format:"tasks CONTAINS[c] '%@'",searchData))
        let editTask = Task()
        let editID = foundTasks[findIndexPath].id
        editTask.id = editID
        editTask.tasks = editData
        try! realm.write {
            realm.add(editTask, update: .all)
        }
    }
    
    func editData(_ toEditTask: String, _ editTaskIndex: Int) {
        let task = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        let editID = task[editTaskIndex].id
        let editTask = Task()
        editTask.id = editID
        editTask.tasks = toEditTask
        try! realm.write {
            realm.add(editTask, update: .all)
        }
    }
    
    func getData(_ getTaskIndex: Int) -> String {
        let task = realm.objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        let getID = task[getTaskIndex].id
        let getTask = realm.objects(Task.self).filter("id = %@", getID).first
        return getTask!.tasks
    }
    
    func addData(_ addTask: String){
        let task = Task()
        task.tasks = addTask
        try! realm.write {
            realm.add(task)
        }
    }
    
    func deleteData(_ delTaskIndex: Int){
        let task = realm.objects(Task.self)
        let delID = task[delTaskIndex].id
        let completeTask = realm.objects(Task.self).filter("id = %@", delID)
        try! realm.write {
            realm.delete(completeTask)
        }
    }
}
