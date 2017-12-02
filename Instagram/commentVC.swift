//
//  commentVC.swift
//  Instagram
//
//  Created by Bobby Negoat on 12/1/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Parse

var commentuuid = [String]()
var commentowner = [String]()

class commentVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentTxt: UITextView!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    var refresh = UIRefreshControl()
    
    // values for reseting UI to default
    var tableViewHeight : CGFloat = 0
    var commentY : CGFloat = 0
    var commentHeight : CGFloat = 0
    
    // arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var commentArray = [String]()
    var dateArray = [Date?]()
    
    // variable to hold keybarod frame
    var keyboard = CGRect()
    
    // page size
    var page:Int32 = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()

      //set views layout
     configueVCAlignment()
        
        // set navigation bar
     configueNavigationBar()
        
          //create back swipe gesture
    createBackSwipeGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
// convert commentTxt to first responder
     //createFirstResponder()
        
        //create observers
        createObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //release observers
        deleteObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendBtn_click(_ sender: Any) {
    
    
    }
    
}//commentVC class over line

//custom functions
extension commentVC{
    
    // convert commentTxt to first responder
    fileprivate func createFirstResponder(){
      
     commentTxt.becomeFirstResponder()
    }

    // set navigation bar
    fileprivate func configueNavigationBar(){
       
    self.navigationItem.title = "COMMENTS"
    self.navigationItem.hidesBackButton = true
    self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "back", style: .plain, target: self, action: #selector(back(_:)))
    }
    
    //create back swipe gesture
    fileprivate func createBackSwipeGesture(){
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
    }
    
    //set views layout
    fileprivate func configueVCAlignment(){
  
     //avoid the issue to auto layout
_ = [tableView,sendBtn,commentTxt].map{$0.translatesAutoresizingMaskIntoConstraints = false}
 
//table view layout
   tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
   tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
   tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
   tableView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier:700 / 812).isActive = true
 
// comment text view layout
  commentTxt.leftAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leftAnchor).isActive = true
  commentTxt.heightAnchor.constraint(equalToConstant: 50).isActive = true
  commentTxt.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 3).isActive = true
  commentTxt.rightAnchor.constraint(equalTo: self.view.layoutMarginsGuide.rightAnchor).isActive = true

 // comment text view layout
sendBtn.rightAnchor.constraint(equalTo: commentTxt.rightAnchor).isActive = true
sendBtn.topAnchor.constraint(equalTo: commentTxt.topAnchor).isActive = true
sendBtn.bottomAnchor.constraint(equalTo: commentTxt.bottomAnchor).isActive = true
  sendBtn.widthAnchor.constraint(equalToConstant: 46).isActive = true
  sendBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true
        
sendBtn.layer.cornerRadius = sendBtn.bounds.size.width / 2
  sendBtn.layer.borderWidth = 1
sendBtn.backgroundColor = #colorLiteral(red: 0.1920000017, green: 0.275000006, blue: 0.5059999824, alpha: 1)
    
 commentTxt.backgroundColor = UIColor.red
 commentTxt.layer.cornerRadius = sendBtn.bounds.size.width / 2
commentTxt.layer.borderColor = UIColor.blue.cgColor
commentTxt.layer.borderWidth = 2
        
        // assign reseting values
        tableViewHeight = tableView.frame.size.height
        commentHeight = commentTxt.frame.size.height
        commentY = commentTxt.frame.origin.y
}
}

//custom functions selectors
extension commentVC{
    
    // go back
    @objc fileprivate func back(_ sender : UIBarButtonItem) {
    
self.navigationController?.popViewController(animated: true)
        
// clean comment uuid from last holding infromation
if !commentuuid.isEmpty {
            commentuuid.removeLast()
        }
        
// clean comment owner from last holding infromation
guard commentowner.isEmpty else{
            commentowner.removeLast()
            return
        }
    }
}

//observers
extension commentVC{
    
    fileprivate func createObservers(){
        
        // catch notification if the keyboard is shown or hidden
        NotificationCenter.default.addObserver(self, selector: #selector(commentVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(commentVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func deleteObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

//observers selectors
extension commentVC{
    
    // func loading when keyboard is shown
   @objc fileprivate func keyboardWillShow(_ notification : Notification) {
        
        // defnine keyboard frame size
       keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
    
   // move UI up
      UIView.animate(withDuration: 0.4)
        { [unowned self] in
        self.tableView.frame.size.height = self.tableViewHeight - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
        self.commentTxt.frame.origin.y = self.commentY - self.keyboard.height - self.commentTxt.frame.size.height + self.commentHeight
        self.sendBtn.frame.origin.y = self.commentTxt.frame.origin.y
            }
    }
    
    // func loading when keyboard is hidden
   @objc fileprivate func keyboardWillHide(_ notification : Notification) {
    
       // move UI down
    UIView.animate(withDuration: 0.4)
            {[unowned self]  in
                self.tableView.frame.size.height = self.tableViewHeight
                self.commentTxt.frame.origin.y = self.commentY
                self.sendBtn.frame.origin.y = self.commentY
            }
   }
}

