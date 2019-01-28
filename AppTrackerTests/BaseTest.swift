//
//  BaseTest.swift
//  AppTrackerTests
//
//  Created by Lena Brusilovski on 26/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import XCTest

extension XCTestCase {
        func waitForAsyncAction(reason:String){
            let expection = self.expectation(description: reason)
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                expection.fulfill()
            }
            self.wait(for: [expection], timeout: 5)
        }
}
