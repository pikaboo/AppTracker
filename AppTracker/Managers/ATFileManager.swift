//
//  ATFileManager.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 25/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit

class ATFileManager: NSObject {

    var cacheDir : FileManager.SearchPathDirectory = .cachesDirectory
    
    convenience init(cacheDir:FileManager.SearchPathDirectory) {
        self.init()
        self.cacheDir = cacheDir
    }
    /**
     Stores any codable object to the disk as a json file
     @param - object, the object to store
     @param - filename, the resulting file name
     */
    func storeObjectToFile<T:Codable>(object:T, filename:String,completion:((Bool)->Void)? = nil){
        let encoder = JSONEncoder()
        let data = try? encoder.encode(object)
        guard data != nil else {
            print("unable to store empty object in file")
            return
        }
        let text = String(data:data!, encoding:.utf8)
        guard text != nil else {
            print("was unable to convert data to string to store in a file")
            return
        }
        storeTextFile(file: filename, text: text!,completion: completion)
        
    }
    
    /**
     Stores test file to the disk
     @param - file , the file name
     @param - text, the text to store
     @param - completion, be notified when finished writing the file
     */
    func storeTextFile(file:String, text:String, completion:((Bool)->Void)? = nil) {
        DispatchQueue.global().async {
            if let dir = self.cacheDirURL() {
                let fileURL = dir.appendingPathComponent(file)
                print("fileURL:\(fileURL)")
                do {
                    try text.data(using: .utf8)?.append(toFileAt: fileURL)
                    completion?(true)
                }
                catch let writingError {
                    print("could not write \(file) to disk:\(writingError)")
                    completion?(false)
                }
            }
        }
        
    }
    
    fileprivate func cacheDirURL()-> URL? {
        let dir = FileManager.`default`.urls(for: self.cacheDir, in: .userDomainMask).first
        return dir
    }
    
    /**
     Reads the contents of a file from disk
     @param - file, the file name to read from
     @param completion - the callback in which to receive the read file
     */
    func readFileFromDisk(file:String, _ completion: ((String?)->Void)? ) -> Void{
        DispatchQueue.global().async {
            if let dir = self.cacheDirURL() {
                
                let fileURL = dir.appendingPathComponent(file)
                //reading
                do {
                    let fileText = try String(contentsOf: fileURL, encoding: .utf8)
                    completion?(fileText)
                    return
                }
                catch let readingError{
                    print("unable to read \(file) from disk:\(readingError)")
                }
            }
            completion?(nil)
        }
    }
    
    func deleteFile(file:String, _ completion:((Bool)->Void)? = nil ) ->Void {
        DispatchQueue.global().async {
            if let dir = self.cacheDirURL() {
                
                let fileURL = dir.appendingPathComponent(file)
                do {
                    let fileManager = FileManager.default
                    try fileManager.removeItem(at: fileURL)
                    return
                }
                catch let readingError{
                    print("unable to read \(file) from disk:\(readingError)")
                }
            }
            completion?(false)
        }
    }
}

extension Data {
    func append(toFileAt fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
            fileHandle.write("\n".data(using: .utf8)!)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
