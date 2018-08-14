//
//  ComentTableViewCell.swift
//  Instagram
//
//  Created by 小嶋暸太 on 2018/08/14.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import UIKit

class ComentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPostData(_ postData: PostData){
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
        
    }
    
}
