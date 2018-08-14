//
//  AllComentsViewController.swift
//  Instagram
//
//  Created by 小嶋暸太 on 2018/08/13.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD

class AllComentsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    
    
    var postData: PostData!
    var keyboard = false
    var comentsArray:[ComentData]=[]
    var observing = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let tapGesture:UITapGestureRecognizer=UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // Do any additional setup after loading the view.
        
        //画面タップを無効に
        self.tableView.allowsSelection = false
        
        let nib = UINib(nibName: "ComentTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        //テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableViewAutomaticDimension
        //tableviewのおおよその高さを導き出す。これでスクロールの値などが予測される
        //高さ概算値 = 「縦横比1:1のUIImageViewの高さ(=画面幅)」+「いいねボタン、キャプションラベル、その他余白の高さの合計概算(=100pt)」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 150
        
        
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if keyboard {
            self.textField.becomeFirstResponder()
            keyboard = false
        }
        
        
        let reference = Database.database().reference().child(Const.ComentPath)
        
        if Auth.auth().currentUser != nil{
            if self.observing == false{
                //要素が追加されたら、postarrayに追加して表示する
                
                reference.observe(.childAdded, with: {snapshot in
                    print("DEBUG_PRINT:childaddイベントが発生しました")
                    
                    //postDataクラスを生成して、受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid{
                        let comentData = ComentData(snapshot: snapshot, myId: uid)
                        if comentData.postId == self.postData.id{
                        self.comentsArray.insert(comentData, at: 0)
                            
                            self.tableView.reloadData()
                            print("DEBUG_PRINT:リロードしました")
                        }
                    }
                })
                //要素が変更されたら、街灯のデータを一度postarrayから削除した後に新しいデータを再表示する
                reference.observe(.childChanged, with: {snapshot in
                    print("DEBUG_PRINT:childChangeイベントが発生しました")
                    
                    if let uid = Auth.auth().currentUser?.uid{
                        //postdataクラスを生成して、受けとったデータを設定する
                        let comentData = ComentData(snapshot: snapshot, myId: uid)
                        
                        if comentData.postId == self.postData.id{
                        //保存している配列からIDが同じものを探す
                        var index: Int = 0
                        for coment in self.comentsArray {
                            if coment.id == comentData.id{
                                index = self.comentsArray.index(of: coment)!
                                break
                            }
                        }
                        
                        
                        //差し替えるために一度削除する
                        self.comentsArray.remove(at: index)
                        
                        //削除したところに更新済みのデータを追加する
                        self.comentsArray.insert(comentData, at: index)
                        
                        }
                    }
                    
                })
                
                //上記によってイベントが登録されたのでobservingをtrueにする
                observing = true
                
                tableView.reloadData()
                print("DEBUG_PRINT:リロードしました")
            }
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comentsArray.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //一番上に、ポストデータを表示して、それ以下にコメントが表示されるようにする
        let returnCell: UITableViewCell!
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath) as! ComentTableViewCell
            cell.setPostData(postData)
            cell.likeButton.addTarget(self, action: #selector(handleButton(_:forEvent:)), for: .touchUpInside)
            returnCell = cell
        }else{
            let comentCell = tableView.dequeueReusableCell(withIdentifier: "comentCell", for: indexPath)
            comentCell.textLabel?.text = "\(comentsArray[indexPath.row-1].name!):\(comentsArray[indexPath.row-1].caption!)"
            
            //日付を入れる
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: comentsArray[indexPath.row-1].date!)
            comentCell.detailTextLabel?.text = dateString
            
            returnCell = comentCell
        }
        
        return returnCell
    }
    
    @objc func handleButton(_ sender:UIButton, forEvent event: UIEvent){
        print("DEBUG_PRINT:likeボタンが押されました")
        
        
        //firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid{
            if postData.isliked{
                //すでにいいねをしていた場合は解除するためにIDを取り除く
                var index = -1
                for likeid in postData.likes{
                    if likeid == uid{
                        //解除するためにインデックスを保持しておく
                        index = postData.likes.index(of: likeid)!
                        break
                    }
                }
                postData.likes.remove(at: index)
                postData.isliked=false //このviewではポストデータが更新されないので、一時的に、islikedをここで管理する
            }else{
                postData.likes.append(uid)
                postData.isliked=true
            }
            
            //増えたlikesをfirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)
        }
        
        tableView.reloadData()
    }

    
    
    @IBAction func hundlePostButton(_ sender: Any) {
        
        if textField.text != ""{
        
        let time = Date.timeIntervalSinceReferenceDate
        let name = Auth.auth().currentUser?.displayName
        
        let comentRef = Database.database().reference().child(Const.ComentPath)
        let comentDic = ["caption":textField.text!,"time":String(time),"name":name,"postId": postData.id!]
        comentRef.childByAutoId().setValue(comentDic)
        
        textField.text=""
        }else{
            SVProgressHUD.showError(withStatus: "コメントを入力してください")
        }
        
        tableView.reloadData()
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
