//
//  TasksViewController.swift
//  ToDoListFirebase
//
//  Created by Nikita on 19.05.21.
//

import UIKit
import Firebase

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: Users!
    var ref: DatabaseReference!
    var tasks = Array<Task>()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else { return } // проверяем залогинены мы или нет
        user = Users(user: currentUser) // получили доступ к структуре Users
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks") // дошли до задач
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value) { [weak self] (snapshot) in
            // создали доп массив, чтобы не дублировать значения
            var _tasks = Array<Task>()
            //
            for item in snapshot.children {
                let task = Task(snapshot: item as! DataSnapshot) // получаем такс и кастим его до DataSnapshot
                _tasks.append(task) // добавляем значение в массив
            }
            
            self?.tasks = _tasks // основному массиву передаем новый массив
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = tasks[indexPath.row]
        let isCompleted = task.completed
        let taskTitle = task.title
        cell.textLabel?.text = taskTitle
        toggleCompletion(cell, isCompleted: isCompleted)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    // позволит добавить базовый функционал для удаления ячеек
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // этот метод работает в пару с canEditRowAt indexPath
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    // позволяет выполнить код при нажатии на соответствующую ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) else { return } // проверка на нажатие ячейки
        let task = tasks[indexPath.row] // получили нжный такс
        let isCompleted = !task.completed // меняем на выполненое задание
        
        toggleCompletion(cell, isCompleted: isCompleted) // передали в метод значения
        task.ref?.updateChildValues(["completed": isCompleted]) // передаем значение в базу
        
        tableView.deselectRow(at: indexPath, animated: true) // отменили выделение ячейки при тапе
        
    }
    
    func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
        alertController.addTextField()
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            
            guard let textField = alertController.textFields?.first, textField.text != "" else { return }
            let task = Task(title: textField.text!, userId: (self?.user.uid)!)
            let taskRef = self?.ref.child(task.title.lowercased()) // имя задачи используем в качестве папки, где будет находится сама задача.
            taskRef?.setValue(task.convertToDictionary()) // добавляем задачу через словарик
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
