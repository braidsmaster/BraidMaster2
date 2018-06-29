//
//  DraftListTableViewController.swift
//  BraidMaster
//
//  Created by Andrey Gromov on 28.06.2018.
//  Copyright © 2018 Kirill Lukyanov. All rights reserved.
//

import UIKit

class DraftListTableViewController: UITableViewController {
    var newDir: String = ""
    let instructionDir = NSHomeDirectory() + "/Documents/Instruction/"
    var filesInDirectory: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(instructionDir)
        // создание категории instructionDir
        do {
            try FileManager.default.createDirectory(atPath: instructionDir, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
    getFileFromDisk()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getFileFromDisk()
    }
    
    @IBAction func addInstruction(_ sender: Any) {
        newDir = instructionDir + newFolderNameGenerator() + "/"
        // создание папки
        do {
            try FileManager.default.createDirectory(atPath: newDir, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
        performSegue(withIdentifier: "newInstr", sender: nil)
    }
    
    func newFolderNameGenerator() -> String {
        let charList: [Int] = Array(0...9)
        var newDirName: String = ""
        for i in 0...4 {
            let randomChar: Int = Int(arc4random_uniform(UInt32(charList.count - 1)))
            newDirName += String( charList[randomChar])
        }
        return newDirName
    }
    
    func getFileFromDisk() {
        do {
            filesInDirectory = try FileManager().contentsOfDirectory(atPath: instructionDir)
        } catch let error as NSError {
            print(error)
        }
        print(filesInDirectory)
      tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filesInDirectory.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "draftCell", for: indexPath)
        cell.textLabel?.text = filesInDirectory [indexPath.row]
        // Configure the cell...

        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newInstr" {
        let destinationVc = segue.destination as! TableViewController
        destinationVc.instrFolderName = newDir
        }
        if segue.identifier == "viewInstr" {
            let destinationVc = segue.destination as! TableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
             destinationVc.instrFolderName = instructionDir + filesInDirectory[indexPath.row] + "/"
            }
           
        }
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "viewInstr", sender: nil)
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
