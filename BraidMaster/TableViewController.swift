//
//  TableViewController.swift
//  BraidMaster
//
//  Created by Kirill Lukyanov on 21.06.2018.
//  Copyright © 2018 Kirill Lukyanov. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import AVKit
import AVFoundation

class TableViewController: UITableViewController{

    let instructionDir = NSHomeDirectory() + "/Documents/Instruction/"
    var instructionDirURL: URL {
        get {
            return URL(fileURLWithPath: instructionDir)
        }
    }
    let userDefaults = UserDefaults.standard
    var visibleIP : IndexPath?
    var elementsPATHArray:[String] = []
    var aboutToBecomeInvisibleCell = -1
    var paused: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermission()
        getURLList()
        
        do {
            try FileManager.default.createDirectory(atPath: instructionDir, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
        
        visibleIP = IndexPath.init(row: 0, section: 0)

    }
    
    func getURLList() {
        
        if let data = userDefaults.stringArray(forKey: "list") {
            for value in data {
                elementsPATHArray.append(value)
            }
            
            print("elementsURL: \(elementsPATHArray)")
            tableView.reloadData()
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    @IBAction func addMedia(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    //               // do stuff here /
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
        
        //   let mediaAuthorizationStatus = PHMedia  .authorizationStatus()
    }
    
    


}

extension TableViewController {
    //    MARK: Play video
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPaths = self.tableView.indexPathsForVisibleRows
        var cells = [Any]()
        for ip in indexPaths!{
            if let videoCell = self.tableView.cellForRow(at: ip) as? VideoTableViewCell{
                //                print("Videocell add")
                cells.append(videoCell)
            }else{
                if  let imageCell = self.tableView.cellForRow(at: ip) as? ImageTableViewCell {
                    //                print("ImageCell add")
                    cells.append(imageCell)
                }
            }
        }
        let cellCount = cells.count
        if cellCount == 0 {return}
        if cellCount == 1{
            //            print ("visible = \(indexPaths?[0])")
            if visibleIP != indexPaths?[0]{
                visibleIP = indexPaths?[0]
            }
            if let videoCell = cells.last! as? VideoTableViewCell{
                self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?.last)!)
            }
        }
        if cellCount >= 2 {
            for i in 0..<cellCount{
                let cellRect = self.tableView.rectForRow(at: (indexPaths?[i])!)
                let completelyVisible = self.tableView.bounds.contains(cellRect)
                let intersect = cellRect.intersection(self.tableView.bounds)
                
                let currentHeight = intersect.height
                
                let cellHeight = (cells[i] as AnyObject).frame.size.height

                if currentHeight > (cellHeight * 0.4){

                    if visibleIP != indexPaths?[i]{
  
                        visibleIP = indexPaths?[i]
          
                        if let videoCell = cells[i] as? VideoTableViewCell{
                            self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?[i])!)
                            videoCell.videoFrame()
                        }
                        if let imageCell = cells[i] as? ImageTableViewCell{
                            imageCell.iconFrame()
                        }
                    }
                }
                else{
                    if aboutToBecomeInvisibleCell != indexPaths?[i].row{
                        aboutToBecomeInvisibleCell = (indexPaths?[i].row)!
                        if let videoCell = cells[i] as? VideoTableViewCell{
                            self.stopPlayBack(cell: videoCell, indexPath: (indexPaths?[i])!)
                        }
                        
                    }
                }
            }
        }
    }
    
    
    
    func playVideoOnTheCell(cell : VideoTableViewCell, indexPath : IndexPath){
        //        print("play")
        cell.startPlayback()
    }
    
    
    func stopPlayBack(cell : VideoTableViewCell, indexPath : IndexPath){
        cell.stopPlayback()
    }
    
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        print("end = \(indexPath)")
        if let videoCell = cell as? VideoTableViewCell{
            videoCell.stopPlayback()
        }
        
        paused = true
    }
}

extension TableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    //MARK: Get media from libraru
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerControllerMediaType] as? String == "public.image" {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            
            let newFileName = String(elementsPATHArray.count*10)
            elementsPATHArray.append(newFileName)
            print("SAVE elementsURL: \(elementsPATHArray)")
            userDefaults.set(elementsPATHArray, forKey: "list")
            let instructionNewFileURL = instructionDirURL.appendingPathComponent(newFileName, isDirectory: true)
            
            let data = UIImagePNGRepresentation(image.fixedOrientation()!)
            FileManager.default.createFile(atPath: instructionNewFileURL.path, contents: data, attributes: nil)
            
            tableView.reloadData()
//            let lastSectionIndex = self.tableView.numberOfSections - 1
//            let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
//            let pathToLastRow =  IndexPath(row: lastRowIndex, section: lastSectionIndex)
//            tableView.beginUpdates()
//
//            tableView.insertRows(at: , with)
//
//            tableView.endUpdates()
            
            
        } else if let mediaType = info[UIImagePickerControllerMediaType] as? String,
            mediaType == (kUTTypeMovie as String),
            let url = info[UIImagePickerControllerMediaURL] as? URL{
            print("mediatype: ",url)
            let newFileName = String(elementsPATHArray.count*10) + ".MOV"
            let instructionNewFileURL = instructionDirURL.appendingPathComponent(newFileName, isDirectory: true)
            elementsPATHArray.append(newFileName)
            print("SAVE elementsURL: \(elementsPATHArray)")
            userDefaults.set(elementsPATHArray, forKey: "list")
            do {
                
                try FileManager.default.moveItem(at: url, to: instructionNewFileURL)
                
            } catch {
                
                print (error)
            }
            tableView.reloadData()
            print(url)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // если в галерее нажали отмену закрывает галерею
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension TableViewController {
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return elementsPATHArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let image = UIImage(contentsOfFile: instructionDir + elementsPATHArray[indexPath.row]) {
            //            if let image  = elementsArray[indexPath.row] as? UIImage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell
            //                cell.picture.image = image
            
            cell.setImage(imageName: image)
            
            let const = cell.picture.image!.size.height / cell.picture.image!.size.width
            tableView.rowHeight =  cell.frame.size.width * const
            
            print("img",tableView.rowHeight)
            return cell
            
        } else {
            
            let url = instructionDir + elementsPATHArray[indexPath.row]
            print("url string \(url)")
            let fullUrl = URL(fileURLWithPath: url)
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoTableViewCell
            let resolution = cell.resolutionForLocalVideo(url: fullUrl)
            cell.videoPlayerItem = AVPlayerItem.init(url: fullUrl)
            if let res = resolution {
                let const = res.height / res.width
                tableView.rowHeight = ceil(cell.frame.size.width * const)
            }
            cell.videoFrame()
            print("video",tableView.rowHeight)
            //                print(resolution)
            return cell
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // indexPath.row это номер ячейки
        
        let fileName = elementsPATHArray[indexPath.row]
        
        do {
            let ipath = instructionDir + "\(fileName)"
            try FileManager.default.removeItem(atPath: ipath)
    
            print("file deleted \(ipath)")
        } catch let error as NSError {
            print("error deleting file: \(error.localizedDescription)")
        }
        
        elementsPATHArray.remove(at: indexPath.row)
        print("SAVE elementsURL: \(elementsPATHArray)")
        userDefaults.set(elementsPATHArray, forKey: "list")
        
        //        elementsArray.remove(at: indexPath.row)
        //        numbersFileInDirectory.remove(at: indexPath.row)
        print (elementsPATHArray)
        //      tableView.reloadData()
        
        //
        
        tableView.beginUpdates()
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        tableView.endUpdates()
        
        //    print ("delete row")
    }
    func scrollToLastRow() {
        let lastSectionIndex = self.tableView.numberOfSections - 1
        let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
        let pathToLastRow =  IndexPath(row: lastRowIndex, section: lastSectionIndex)
        // Make the last row visibl
        self.tableView.scrollToRow(at: pathToLastRow, at: UITableViewScrollPosition.none, animated: true)
    }
    
    
}
