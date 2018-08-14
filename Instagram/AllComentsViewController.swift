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

class AllComentsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
   
    
    
    var postData: PostData!
    
    var comentsArray:[ComentData]=[]
    var observing = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        textField.delegate = self
        
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
        
        
        // キーボードイベントの監視開始
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeShown(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        
        
        
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
                
                self.tableView.reloadData()
                print("DEBUG_PRINT:リロードしました")
            }
        }else{
            if observing == true{
                //ログアウトを検出したら、いったんテーブルを削除して、オブサーバーをクリアする
                //テーブルをクリアする
                comentsArray = []
                self.tableView.reloadData()
                
                //オブサーバーを削除する
                Database.database().reference().removeAllObservers()
                
                //上記によってオブサーバが解除されたので、observingをfalseにする
                observing = false
        }
        
    }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // キーボードイベントの監視解除
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillShow,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillHide,
                                                  object: nil)
    }
    
  
    
    // MARK: - UITextFieldDelegate

    
    
    
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
    
    
    // キーボードが表示された時に呼ばれる
    @objc func keyboardWillBeShown(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                restoreScrollViewSize()
                
                let convertedKeyboardFrame = scrollView.convert(keyboardFrame, from: nil)
                // 現在選択中のTextFieldの下部Y座標とキーボードの高さから、スクロール量を決定
                let offsetY: CGFloat = self.textField.frame.maxY - convertedKeyboardFrame.minY
                if offsetY < 0 { return }
                updateScrollViewSize(moveSize: offsetY, duration: animationDuration)
            }
        }
    }
    
    // キーボードが閉じられた時に呼ばれる
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        restoreScrollViewSize()
    }
    
    // リターンが押された時
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    // moveSize分Y方向にスクロールさせる
    func updateScrollViewSize(moveSize: CGFloat, duration: TimeInterval) {
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(duration)
        
        let contentInsets = UIEdgeInsetsMake(0, 0, moveSize, 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.scrollView.contentOffset = CGPoint(x: 0, y: moveSize)
        
        UIView.commitAnimations()
    }
    
    func restoreScrollViewSize() {
        // キーボードが閉じられた時に、スクロールした分を戻す
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
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
