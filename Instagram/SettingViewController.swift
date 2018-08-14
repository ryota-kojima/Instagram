//
//  SettingViewController.swift
//  Instagram
//
//  Created by 小嶋暸太 on 2018/08/09.
//  Copyright © 2018年 小嶋暸太. All rights reserved.
//

import UIKit
import ESTabBarController
import Firebase
import FirebaseAuth
import SVProgressHUD

class SettingViewController: UIViewController {
    
    @IBOutlet weak var displayNameTextField: UITextField!
    
    @IBAction func hadleChangeButton(_ sender: Any) {
        if let displayname = displayNameTextField.text{
            if displayname.isEmpty{
                SVProgressHUD.showError(withStatus: "表示名を入力して下さい")
                return
            }
            
            //表示名を設定する
            let user = Auth.auth().currentUser
            if let user = user{
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayname
                changeRequest.commitChanges{error in
                    if let error = error{
                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました")
                        print("DEBUG_PRINT:"+error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT:[displayNmae=\(user.displayName!)]の設定に成功しました")
                    
                    //HUDで変更を知らせる
                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
                }
            }
        }
        
    }
    @IBAction func hundleLogoutButton(_ sender: Any) {
        //ログアウトする
        
        try! Auth.auth().signOut()
        
        //ログイン画面の表示
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)
        
        //ログイン画面から戻ってきた時にホーム画面を選択している状態にする
        let tabController = parent as! ESTabBarController
        tabController.setSelectedIndex(0, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //表示名を取得して、テキストフィールドに設定する
        let user = Auth.auth().currentUser
        if let user = user{
            displayNameTextField.text=user.displayName
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
