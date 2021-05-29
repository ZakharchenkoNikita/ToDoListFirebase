//
//  Task.swift
//  ToDoListFirebase
//
//  Created by Nikita on 26.05.21.
//

import Foundation
import Firebase

struct Task {
    
    let title: String
    let userId: String
    let ref: DatabaseReference? // для того, чтобы добраться до конкретного объекта
    var completed: Bool = false
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    // snapshot - это и есть json
    init(snapshot: DataSnapshot) { // DataSnapshot - для получения текущего значения данных из базы
        let snapshotValue = snapshot.value as! [String: AnyObject]
        title = snapshotValue["title"] as! String
        userId = snapshotValue["userId"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func convertToDictionary() -> Any {
        return ["title": title, "userId": userId, "completed": completed]
    }
}
