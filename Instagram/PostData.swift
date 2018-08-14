//
//  PostData.swift
//  Instagram
//
//  Created by 小嶋暸太 on 2018/08/10.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class PostData:NSObject{
    var id: String?
    var image: UIImage?
    var imageString: String?
    var name: String?
    var caption: String?
    var date: Date?
    var likes: [String] = []
    var isliked: Bool = false
    
    init(snapshot: DataSnapshot, myId: String){
        self.id = snapshot.key//keyはそれが生成された場所、この例でいうとautosetidが返されるはず
        
        let valueDictionary = snapshot.value as! [String: Any]
        imageString = valueDictionary["image"] as? String
        image = UIImage(data: Data(base64Encoded: imageString!, options: .ignoreUnknownCharacters)!)
        
        self.name = valueDictionary["name"] as? String
        
        self .caption = valueDictionary["caption"] as? String
        
        let time = valueDictionary["time"] as? String
        self.date = Date(timeIntervalSinceReferenceDate: TimeInterval(time!)!)
        
        if let likes = valueDictionary["likes"] as? [String]{
            self.likes = likes
        }
        
        for likeId in self.likes{
            if likeId == myId{
                self.isliked = true
                break
            }
        }
    }
}
