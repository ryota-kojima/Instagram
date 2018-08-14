//
//  LoginViewController.swift
//  Instagram
//
//  Created by 小嶋暸太 on 2018/08/09.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var displayNameTextField: UITextField!
    
    //ログインボタンをタップした時に呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailAddressTextField.text,let password = passwordTextField.text{
            if address.isEmpty || password.isEmpty{
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            //SVProgressで処理中を表示
            SVProgressHUD.show()
            
            //ログイン処理をして成功なら画面を閉じる、ダメなら何もしない
            Auth.auth().signIn(withEmail: address, password: password){ user,error in
                if let error = error{
                    print("DEBUG_PRINT"+error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました")
                    return
                }else{
                    print("DEBUG_PRINT:ログインに成功しました")
                    
                    //SVProgressを消す
                    SVProgressHUD.dismiss()
                    
                    //画面を閉じる
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    //アカウント作成画面をタップした時に呼ばれるメソッド
    @IBAction func hundleCreateAccountButton(_ sender: Any) {
        //それぞれのテキスト取得
        if let address = mailAddressTextField.text,let password = passwordTextField.text,let displayName = displayNameTextField.text{
            //もしもどれかでも空欄だったなら何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty{
                print("DEBUGGER PRINT 何かが空文字です")
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            //SVProgressを表示
            SVProgressHUD.show()
        
        //アドレスとパスワードでユーザーを作成。作成に成功すると自動的にログインする
        Auth.auth().createUser(withEmail: address, password: password){ user,error in
            if let error = error{
                print("DEBUG_PRINT"+error.localizedDescription)
                SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました")
                return
            }
            print("ユーザー作成に成功しました")
            
            //表示名を設定する
            let user = Auth.auth().currentUser
            if let user = user{
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName=displayName
                changeRequest.commitChanges{ error in
                    if let error = error{
                        print("DEBUG_PRINT"+error.localizedDescription)
                        SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました")
                        return
                    }
                    print("DEBUG_PRINT :[displayname = \(user.displayName)]の設定に成功しました。")
                    
                    //SVProguressを閉じる
                    SVProgressHUD.dismiss()
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
