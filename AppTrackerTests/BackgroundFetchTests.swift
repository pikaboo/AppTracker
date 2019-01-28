//
//  BackgroundFetchTests.swift
//  AppTrackerTests
//
//  Created by Lena Brusilovski on 28/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import XCTest
@testable import AppTracker
class BackgroundFetchTests: XCTestCase {

    var trackManagerUnderTest:TrackManager!
    let userDefaultsSuiteName = "BackgroundFetchTests"

    override func setUp() {
       super.setUp()
        UserDefaults().removePersistentDomain(forName: userDefaultsSuiteName)
        let userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)
        self.trackManagerUnderTest = TrackManager(userDefaults: userDefaults!)
        self.trackManagerUnderTest.fileName = "TestFileName"
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults().removePersistentDomain(forName: userDefaultsSuiteName)
    }

    func testBackgroundFetchHandlerIsCalled() {
        let expectation = self.expectation(description: "background fetch to finish")
        self.trackManagerUnderTest.onBackgroundFetchEvent { (handler) in
            print("handler called")
            //this means the callback was called in 30 seconds or less
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 30)
        
    }

    func testInvokingBackgroundFetchEventWritesAnEventToFile(){
        let atFileManager = ATFileManager()
        atFileManager.cacheDir = .documentDirectory
        atFileManager.deleteFile(file: self.trackManagerUnderTest.fileName)
        self.waitForAsyncAction(reason: "delete file")
        //Log file should be empty at this point
        let expectation = self.expectation(description: "background fetch to finish")
        self.trackManagerUnderTest.onBackgroundFetchEvent { (handler) in
            print("handler called")
            //this means the callback was called in 30 seconds or less
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 30)
        
       let readFileExpectation = self.expectation(description: "read file from disk")
        atFileManager.readFileFromDisk(file: self.trackManagerUnderTest.fileName) { (fileContens) in
            let event = BackgroundFetchEvent(coordinate: Coordinate.zero)
            XCTAssertNotNil(fileContens)
            XCTAssertTrue(fileContens!.contains(event.name))
            XCTAssertTrue(fileContens!.contains(event.logDate))
            //testing the location can only be done in ui test, because of the permission dialog
            readFileExpectation.fulfill()
        }
        self.wait(for: [readFileExpectation], timeout: 10)
    }

}
