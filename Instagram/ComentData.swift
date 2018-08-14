//
//  ComentData.swift
//  Instagram
//
//  Created by 小嶋暸太 on 2018/08/13.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class ComentData:NSObject{
    var postId: String?
    var id: String?
    var name: String?
    var caption: String?
    var date: Date?
    
    init(snapshot: DataSnapshot, myId: String){
        id = snapshot.key
        
        
        let valueDictionary = snapshot.value as! [String: Any]
        
        self.postId = valueDictionary["postId"] as? String
    
        self.name = valueDictionary["name"] as? String
        
        self .caption = valueDictionary["caption"] as? String
        
        let time = valueDictionary["time"] as? String
        self.date = Date(timeIntervalSinceReferenceDate: TimeInterval(time!)!)
    }
}
