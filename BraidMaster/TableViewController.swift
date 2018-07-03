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
import FirebaseStorage

class TableViewController: UITableViewController{
    var instrFolderName: String = ""
    var instructionDir = NSHomeDirectory() + "/Documents/Instruction/"
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
    var imageDataDictinary: [Int: UIImage] = [:]
    var rowHeightAtIndexPath: [CGFloat] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        instructionDir = instrFolderName
        print(instrFolderName)

        checkPermission()
        getURLList()

        visibleIP = IndexPath.init(row: 0, section: 0)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadInstruction(_ sender: Any) {
    
    }
    
    @IBAction func backSwipe(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addMedia(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
}

extension TableViewController {
    //    MARK: Files and Permishen
    fileprivate func calculateImageRow( image: UIImage,  indexPath: IndexPath) {
        let const = image.size.height / image.size.width
        let iconWidth: CGFloat = tableView.frame.width
        let iconHeight: CGFloat = iconWidth * const
        rowHeightAtIndexPath.append(iconHeight)
    }
    
    fileprivate func calculateVideoRow( path: String,  indexPath: IndexPath) {
        
        if let resolution = resolutionForLocalVideo(url: URL(fileURLWithPath: instructionDir + path)) {
            let videoConst = resolution.height / resolution.width
            let videoHeight = tableView.frame.width * videoConst
            rowHeightAtIndexPath.append(videoHeight)
        }
    }
    
    func getURLList() {
        
        if let data = userDefaults.stringArray(forKey: instrFolderName) {
            for value in data {
                elementsPATHArray.append(value)
            }
            print("elementsPATHArray")
            for (index,value) in elementsPATHArray.enumerated() {
                let indexPath = IndexPath(row: index, section: 0)
                if let image = UIImage(contentsOfFile: instructionDir + value) {
                    imageDataDictinary[index] = image
                    
                    calculateImageRow(image: image, indexPath: indexPath)
                } else {
                    calculateVideoRow(path: value, indexPath: indexPath)
                }
            }
            print("elementsURL: \(elementsPATHArray)")
            tableView.reloadData()
        }
        
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
    func newFileNameGenerator() -> String {
        let charList: [Int] = Array(0...9)
        var newFileName: String = ""
        for i in 0...8 {
            let randomChar: Int = Int(arc4random_uniform(UInt32(charList.count - 1)))
            newFileName += String( charList[randomChar])
        }
        return newFileName
    }
    
    func uploadFile () {
        
        let path = Bundle.main.path(forResource: "IMG_5004", ofType:"MOV")
        let data = try! Data (contentsOf: URL(fileURLWithPath: path!) )
        
        // Create a root reference
        let storageRef = Storage.storage().reference()
        
        let uuid = UUID().uuidString
        
        // Create a reference to the file you want to upload
        let imageRef = storageRef.child("testvideos/\(uuid)")
        
        // Upload the file
        imageRef.putData(data, metadata: nil) { (_,_) in
            print("image done")
        }
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
                            //                            videoCell.videoFrame()
                        }
                        if let imageCell = cells[i] as? ImageTableViewCell{
                            //                            imageCell.iconFrame()
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
    
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        //        self.videoResolution = CGSize(width: fabs(size.width), height: fabs(size.height))
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
}

extension TableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    //MARK: Get media from library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        DispatchQueue.global(qos: .userInteractive).async {
            
            if info[UIImagePickerControllerMediaType] as? String == "public.image" {
                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                
                
                let newFileName = self.newFileNameGenerator()
                self.imageDataDictinary[self.elementsPATHArray.count] = image
                self.elementsPATHArray.append(newFileName)
                print("SAVE elementsURL: \(self.elementsPATHArray)")
                self.userDefaults.set(self.elementsPATHArray, forKey: self.instrFolderName)
                let instructionNewFileURL = self.instructionDirURL.appendingPathComponent(newFileName, isDirectory: true)
                
                let data = UIImagePNGRepresentation(image.fixedOrientation()!)
                FileManager.default.createFile(atPath: instructionNewFileURL.path, contents: data, attributes: nil)
                
                DispatchQueue.main.sync {
                    let indexPath = IndexPath(row: self.elementsPATHArray.count - 1, section: 0)
                    self.calculateImageRow(image: image, indexPath: indexPath)
                    self.tableView.beginUpdates()
                    
                    self.tableView.insertRows(at: [indexPath], with: .bottom)
                    
                    self.tableView.endUpdates()
                    self.scrollToLastRow()
                }
                
                
            } else if let mediaType = info[UIImagePickerControllerMediaType] as? String,
                mediaType == (kUTTypeMovie as String),
                let url = info[UIImagePickerControllerMediaURL] as? URL{
                print("mediatype: ",url)
                let newFileName = self.newFileNameGenerator() + ".MOV"
                let instructionNewFileURL = self.instructionDirURL.appendingPathComponent(newFileName, isDirectory: true)
                self.elementsPATHArray.append(newFileName)
                print("SAVE elementsURL: \(self.elementsPATHArray)")
                self.userDefaults.set(self.elementsPATHArray, forKey: self.instrFolderName)
                do {
                    
                    try FileManager.default.moveItem(at: url, to: instructionNewFileURL)
                    
                } catch {
                    
                    print (error)
                }
                DispatchQueue.main.sync {
                    let indexPath = IndexPath(row: self.elementsPATHArray.count - 1, section: 0)
                    self.calculateVideoRow(path: newFileName, indexPath: indexPath)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [indexPath], with: .bottom)
                    self.tableView.endUpdates()
                    self.scrollToLastRow()
                }
            }
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell
            
            
            if let image = imageDataDictinary[indexPath.row] {
                cell.setImage(imageName: image)
            }
            
            return cell
            
        } else {
            
            let url = instructionDir + elementsPATHArray[indexPath.row]
            print("url string \(url)")
            let fullUrl = URL(fileURLWithPath: url)
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoTableViewCell
            
            cell.videoPlayerItem = AVPlayerItem.init(url: fullUrl)
            
            
            print("video",tableView.rowHeight)
            return cell
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // indexPath.row это номер ячейки
        DispatchQueue.global(qos: .userInteractive).async {
            
            
            let fileName = self.elementsPATHArray[indexPath.row]
            
            do {
                let ipath = self.instructionDir + "\(fileName)"
                try FileManager.default.removeItem(atPath: ipath)
                
                print("file deleted \(ipath)")
            } catch let error as NSError {
                print("error deleting file: \(error.localizedDescription)")
            }
            //self.imageDataDictinary.removeValue(forKey: indexPath.row)
            self.rowHeightAtIndexPath.remove(at: indexPath.row)
            self.elementsPATHArray.remove(at: indexPath.row)
            
            
            print("SAVE elementsURL: \(self.elementsPATHArray)")
            self.userDefaults.set(self.elementsPATHArray, forKey: self.instrFolderName)
            for (index,value) in self.elementsPATHArray.enumerated() {
                if let image = UIImage(contentsOfFile: self.instructionDir + value) {
                    self.imageDataDictinary[index] = image
                    
                }
            }
            
            
            DispatchQueue.main.sync {
                
                tableView.beginUpdates()
                
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                tableView.endUpdates()
                
            }
            
            
        }
    }
    
    func scrollToLastRow() {
        let lastSectionIndex = self.tableView.numberOfSections - 1
        let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
        let pathToLastRow =  IndexPath(row: lastRowIndex, section: lastSectionIndex)
        // Make the last row visibl
        self.tableView.scrollToRow(at: pathToLastRow, at: UITableViewScrollPosition.none, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return rowHeightAtIndexPath[indexPath.row]
    }
    
    
}


// SAVE elementsURL: ["554143712.MOV", "151152884", "581773780.MOV", "828371147.MOV", "756000625", "802740276.MOV", "550057871", "233528170", "601361311.MOV", "015378204", "448507651.MOV"]
