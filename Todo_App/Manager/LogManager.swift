//
//  LogManager.swift
//  Todo_App
//
//  Created by admin on 27/10/25.
//

import Foundation
import SwiftyBeaver

let log = SwiftyBeaver.self

//Can use Logger replace for SwiftyBeaver
private class Logger {
    class func verbose() {}
    class func debug() {}
    class func info() {}
    class func warning() {}
    class func error() {}
}
