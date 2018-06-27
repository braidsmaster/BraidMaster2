//
//  InstructionData.swift
//  BraidMaster
//
//  Created by Kirill Lukyanov on 25.06.2018.
//  Copyright © 2018 Kirill Lukyanov. All rights reserved.
//

import Foundation
import UIKit

class InstructionData: Codable {
    var path: String
    var image: UIImage?
    init(path: String, image: UIImage?) {
        self.path = path
        self.image = image
    }
//    convenience init(path: String) {
//        self.init(path: path, image: nil)
//    }
//    
//    public static func saveInstructionData(dataList: [InstructionData]){
//        let dataToWrite = try! JSONEncoder().encode(dataList)
//        UserDefaults.standard.set(dataToWrite, forKey: "data")
//    }
//
//    public static func getInstructionData() -> [InstructionData]?{
//        let getDataFromDisk = UserDefaults.standard.data(forKey: "data")
//        let instructionList = try! JSONDecoder().decode([InstructionData].self, from: getDataFromDisk!)
//        return instructionList
//    }
//
}

extension UserDefaults {
    func decode<T : Codable>(for type : T.Type, using key : String) -> T? {
        let defaults = UserDefaults.standard
        guard let data = defaults.object(forKey: key) as? Data else {return nil}
        let decodedObject = try? PropertyListDecoder().decode(type, from: data)
        return decodedObject
    }
    
    func encode<T : Codable>(for type : T, using key : String) {
        let defaults = UserDefaults.standard
        let encodedData = try? PropertyListEncoder().encode(type)
        defaults.set(encodedData, forKey: key)
        defaults.synchronize()
    }
}
