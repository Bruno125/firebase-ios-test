//
//  TextViewController.swift
//  FirebaseTest
//
//  Created by Bruno Aybar on 04/03/2017.
//  Copyright © 2017 Bruno Aybar. All rights reserved.
//

import UIKit
import Firebase

struct TextEntry {
    var value : String
    var delay : String
    var size : String
    
    static func parse(data: FIRDataSnapshot) -> TextEntry?{
        let info = data.value as? NSDictionary
        
        let value = info?["value"] as? String ?? ""
        let size = "\(value.utf8.count) bytes"
        let timestamp = info?["timestamp"] as? String ?? ""
        let timestampDate = Date.init(timeIntervalSince1970: Double(timestamp)!)
        let delay = (Date().timeIntervalSince(timestampDate) * 1000)
        
        guard info != nil, !value.isEmpty, delay < 60 * 1000 else{
            return nil
        }
        let delayText =  "\(delay) milliseconds"
        return TextEntry(value: value, delay: delayText, size: size)
    }
    
}

class TextViewController : UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var textField: UITextField!
    
    var ref: FIRDatabaseReference!
    
    
    
    var entries : [TextEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        ref = FIRDatabase.database().reference()
        setup()
    }
    
    
    
    @IBAction func actionSend(_ sender: Any) {
        guard let text = textField.text else {
            return
        }
        send(text: text)
    }
    
    @IBAction func actionSendBulk(_ sender: Any) {
        let text = JsonFileReader.read(file: "info")
        send(text: text)
    }
    
    func send(text: String){
        
        let stamp = "\(Date().timeIntervalSince1970)"
        self.ref.child("texts").childByAutoId().setValue( [ "value" : text, "timestamp" : stamp ] )
    }
    
    
    func setup(){
        
        let textsRefs = ref.child("texts")
        
        // Listen for new comments in the Firebase database
        textsRefs.observe(.childAdded, with: { (snapshot) -> Void in
            guard let entry = TextEntry.parse(data: snapshot) else{
                return
            }
            self.entries.append(entry)
            self.tableView.insertRows(at: [IndexPath(row: self.entries.count-1, section: 0)], with: UITableViewRowAnimation.automatic)
        })
    }
    
    @IBAction func actionClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension TextViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TextEntryCell
        let info = entries[indexPath.row]
        
        cell.valueLabel.text = info.value
        cell.sizeLabel.text = info.size
        cell.delayLabel.text = info.delay
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
