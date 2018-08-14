//
//  HomeViewController.swift
//  Instagram
//
//  Created by 小嶋暸太 on 2018/08/09.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import UIKit
import ESTabBarController
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var comentPostData:PostData!//コメントがタップされた時に明け渡すpostdata
    
    var postArray: [PostData] = []
    
    var comentsArray: [ComentData] = []
    
    //databaseのobserveEventの登録状態を表す
    var observing = false
    var comentobserving = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //画面タップを無効に
        self.tableView.allowsSelection = false
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        //テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableViewAutomaticDimension
        //tableviewのおおよその高さを導き出す。これでスクロールの値などが予測される
        //高さ概算値 = 「縦横比1:1のUIImageViewの高さ(=画面幅)」+「いいねボタン、キャプションラベル、その他余白の高さの合計概算(=100pt)」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 150
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print("DEBUG_PRINT:ViewWillAppear")
        
        //コメントを取得
        observingComent()
        
        if Auth.auth().currentUser != nil{
            if self.observing == false{
                //要素が追加されたら、postarrayに追加して表示する
                let postRef = Database.database().reference().child(Const.PostPath)
                postRef.observe(.childAdded, with: {snapshot in
                    print("DEBUG_PRINT:childaddイベントが発生しました")
                    
                    //postDataクラスを生成して、受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid{
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at: 0)
                        
                        //tableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                //要素が変更されたら、街灯のデータを一度postarrayから削除した後に新しいデータを再表示する
                postRef.observe(.childChanged, with: {snapshot in
                    print("DEBUG_PRINT:childChangeイベントが発生しました")
                    
                    if let uid = Auth.auth().currentUser?.uid{
                        //postdataクラスを生成して、受けとったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        //保存している配列からIDが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id{
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        //差し替えるために一度削除する
                        self.postArray.remove(at: index)
                        
                        //削除したところに更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        //TabaleViewを更新する
                        self.tableView.reloadData()
                    }
                    
                    })
                
                //上記によってイベントが登録されたのでobservingをtrueにする
                observing = true
            }
        }else{
            if observing == true{
                //ログアウトを検出したら、いったんテーブルを削除して、オブサーバーをクリアする
                //テーブルをクリアする
                postArray = []
                tableView.reloadData()
                
                //オブサーバーを削除する
                Database.database().reference().removeAllObservers()
                
                //上記によってオブサーバが解除されたので、observingをfalseにする
                observing = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath) as! PostTableViewCell
        
        var comentarray:[ComentData]=[]
        
        //postに投稿されたコメントだけを取得
        for coment in comentsArray{
            if coment.postId == postArray[indexPath.row].id{
                comentarray.append(coment)
            }
        }
        
        cell.setPostData(postArray[indexPath.row],comentarray)
        
        //セル内のボタンのアクションをコードで記述する
        cell.likeButton.addTarget(self, action: #selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.comentButton.addTarget(self, action: #selector(handleComentButton(_:forEvent:)), for: .touchUpInside)
        cell.allComentButton.addTarget(self, action: #selector(handleComentShowButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func handleComentButton(_ sender:UIButton, forEvent event: UIEvent){
        print("DEBUG_PRINT:コメントボタンが押されました")
        
        //タップされた時のIndexを求める
        let touch = event.allTouches?.first
        let point = touch?.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point!)
        
        //配列からタップされたインデックスのデータを取り出す
        comentPostData = postArray[indexPath!.row]
        
        performSegue(withIdentifier: "comentSegue", sender: nil)
    }
    
    @objc func handleComentShowButton(_ sender:UIButton, forEvent event: UIEvent){
        print("DEBUG_PRINT:コメントショウボタンが押されました")
        
        //タップされた時のIndexを求める
        let touch = event.allTouches?.first
        let point = touch?.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point!)
        
        //配列からタップされたインデックスのデータを取り出す
        comentPostData = postArray[indexPath!.row]
        
        performSegue(withIdentifier: "allComentSegue", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleButton(_ sender:UIButton, forEvent event: UIEvent){
        print("DEBUG_PRINT:likeボタンが押されました")
        
        //タップされた時のIndexを求める
        let touch = event.allTouches?.first
        let point = touch?.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point!)
        
        //配列からタップされたインデックスのデータを取り出す
        let postdata = postArray[indexPath!.row]
        
        //firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid{
            if postdata.isliked{
                //すでにいいねをしていた場合は解除するためにIDを取り除く
                var index = -1
                for likeid in postdata.likes{
                    if likeid == uid{
                        //解除するためにインデックスを保持しておく
                        index = postdata.likes.index(of: likeid)!
                        break
                    }
                }
                postdata.likes.remove(at: index)
            }else{
                postdata.likes.append(uid)
            }
            
            //増えたlikesをfirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postdata.id!)
            let likes = ["likes":postdata.likes]
            postRef.updateChildValues(likes)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let allComentViewController: AllComentsViewController! = segue.destination as! AllComentsViewController
        
        if segue.identifier == "comentSegue"{
            allComentViewController.postData = comentPostData
            allComentViewController.keyboard = true
        }else if segue.identifier == "allComentSegue"{
            allComentViewController.postData = comentPostData
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //コメントデータの取得
    func observingComent(){
        let reference = Database.database().reference().child(Const.ComentPath)
        
        if Auth.auth().currentUser != nil{
            if self.comentobserving == false{
                //要素が追加されたら、postarrayに追加して表示する
                
                reference.observe(.childAdded, with: {snapshot in
                    print("DEBUG_PRINT:childaddイベントが発生しました")
                    
                    //postDataクラスを生成して、受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid{
                        let comentData = ComentData(snapshot: snapshot, myId: uid)
                        self.comentsArray.insert(comentData, at: 0)
                        
                        self.tableView.reloadData()
                    }
                })
                //要素が変更されたら、街灯のデータを一度postarrayから削除した後に新しいデータを再表示する
                reference.observe(.childChanged, with: {snapshot in
                    print("DEBUG_PRINT:childChangeイベントが発生しました")
                    
                    if let uid = Auth.auth().currentUser?.uid{
                        //postdataクラスを生成して、受けとったデータを設定する
                        let comentData = ComentData(snapshot: snapshot, myId: uid)
                        
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
                    
                })
                
                //上記によってイベントが登録されたのでobservingをtrueにする
                comentobserving = true
            }
        }
        
    }
    @IBAction func unwind(_ segue: UIStoryboardSegue){
        
    }
}
