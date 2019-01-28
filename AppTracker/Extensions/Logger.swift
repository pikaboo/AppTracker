//
//  Logger.swift
//  AppTracker
//
//  Created by Lena Brusilovski on 27/01/2019.
//  Copyright © 2019 Lena Brusilovski. All rights reserved.
//

import UIKit


func log(_ items: Any..., file:String = #file,line:Int = #line,  separator: String = " ", terminator: String = "\n"){
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let timestamp = dateFormatter.string(from: Date())
    let itemsOutput = items.map { "\($0)" }.joined(separator: separator)
    let fileName = URL(string: file)?.lastPathComponent
    Swift.print(timestamp, fileName ?? file, line, itemsOutput,terminator:terminator)
}
