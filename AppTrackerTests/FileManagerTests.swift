//
//  FileManagerTests.swift
//  AppTrackerTests
//
//  Created by Lena Brusilovski on 26/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import XCTest
@testable import AppTracker
import CoreMotion
class FileManagerTests: XCTestCase {

    var atFileManager: ATFileManager!
    override func setUp() {
        self.atFileManager = ATFileManager()
    }
    
    override func tearDown() {
        self.atFileManager = nil
    }
    
    func testCanStoreFile(){
        let fileName = "Lena"
        let contentsOfTextFile = "Text Stored by Lena In a test"
        self.atFileManager.storeTextFile(file: fileName, text:contentsOfTextFile )
        self.waitForAsyncAction(reason: "Wait for file to be written")
        self.atFileManager.readFileFromDisk(file: fileName){
            storedText in
            XCTAssertNotNil(storedText)
            XCTAssertEqual(storedText!, contentsOfTextFile)
        }
        self.waitForAsyncAction(reason: "wait for file to load")
        
    }
    
    func testCanWriteBackgroundFetchEventToDisk(){
        let filename = "BackgroundFetchStoredFile"
        let backgroundFetchEvent = BackgroundFetchEvent(coordinate: Coordinate.zero)
        atFileManager.storeObjectToFile(object: backgroundFetchEvent, filename: filename)
        self.waitForAsyncAction(reason: "Wait for file to be written")
        
        self.atFileManager.readFileFromDisk(file: filename) {
            fileContents in
            XCTAssertNotNil(fileContents)
            XCTAssertTrue(fileContents!.contains("\"name\":\"BackgroundFetchEvent\""))
            XCTAssertTrue(fileContents!.contains("\"logDate\":\"\(backgroundFetchEvent.logDate!)\""))
        }
        
        self.waitForAsyncAction(reason: "wait for file to load")
        self.atFileManager.deleteFile(file: "BackgroundFetchStoredFile")
        self.waitForAsyncAction(reason: "wait for file to delete")
    }
    

}
