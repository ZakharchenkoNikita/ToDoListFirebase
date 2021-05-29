//
//  User.swift
//  ToDoListFirebase
//
//  Created by Nikita on 26.05.21.
//

import Foundation
import Firebase

struct Users {
    
    let uid: String
    let email: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
