//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 小嶋暸太 on 2018/08/10.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var allComentButton: UIButton!
    @IBOutlet weak var comentButton: UIButton!
    
    @IBOutlet weak var comentLabel: UILabel!
    
    @IBOutlet weak var captionBottomSafe: NSLayoutConstraint!
    @IBOutlet weak var allComentButtonTopcaption: NSLayoutConstraint!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPostData(_ postData:PostData,_ comentarray:[ComentData]){
     
        //コメントがあるときは、コメントラベルとボタンの表示。
        //コメントがないときは、Hideにして、キャプションの制約を変更し、隙間を埋める
        if comentarray.count == 0{
            allComentButton.isHidden = true
            comentLabel.isHidden = true
            allComentButtonTopcaption.isActive=false
            captionBottomSafe.isActive=true
            
        }else{
            captionBottomSafe.isActive=false
            allComentButtonTopcaption.isActive=true
            allComentButton.isHidden = false
            comentLabel.isHidden = false
            self.allComentButton.setTitle("コメント\(comentarray.count)件全てを表示",for: .normal)
        }
        
        
        self.postImageView.image=postData.image
        
        self.captionLabel.text="\(postData.name!) : \(postData.caption!)"
        let likenumber = postData.likes.count
        likeLabel.text="「いいね！」\(likenumber)件"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: postData.date!)
        self.dateLabel.text = dateString
        
        if postData.isliked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        }else{
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        //必要なコメントを取得
       
        
        if comentarray.count >= 3{
            comentLabel.text = "\(comentarray[0].name!):\(comentarray[0].caption!)\n"+"\(comentarray[1].name!):\(comentarray[1].caption!)\n"+"\(comentarray[2].name!):\(comentarray[2].caption!)"
        }else if comentarray.count == 2{
           comentLabel.text = "\(comentarray[0].name!):\(comentarray[0].caption!)\n"+"\(comentarray[1].name!):\(comentarray[1].caption!)"
        }else if comentarray.count == 1{
            comentLabel.text = "\(comentarray[0].name!):\(comentarray[0].caption!)"
        }
        }
    }

