//
//  Learner.swift
//  Drumstik
//
//  Created by Omar Al-Ejel on 3/30/19.
//  Copyright © 2019 Omar Al-Ejel. All rights reserved.
//

import CoreML
import SandboxBrowser

@objc @objcMembers public class Learner: NSObject {
    static var _shared = Learner()
    
    var learningData: [(Double, Bool)] = []
    var savingCSV = false
    
    var csvStream: OutputStream?
    var csvWriter: CSV.Writer?
    
    override init() {
        learningData.reserveCapacity(1_000_000)
    }
    
    public func append(datum: Double, isHit h: Bool) {
        if !savingCSV {
            learningData.append((datum, h))
        }
    }
    
    open class func shared() -> Learner {
        return _shared
    }
    
    func newSessionFilePath() -> String {
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let formatter = DateFormatter()
        formatter.dateFormat = "d.M.YY-hh:mm:ss"
        let x = docDir + "/Accelerometer-\(formatter.string(from: Date())).csv"
        return x
    }
    
    public func saveCSV() {
        csvStream?.close()
        
        savingCSV = true
        let csvPath = newSessionFilePath()
        
        if let stream = OutputStream(toFileAtPath: csvPath, append: false) {
            csvStream = stream
            let config = CSV.Configuration(delimiter: ",", encoding: .utf8)
            csvWriter = CSV.Writer(outputStream: stream, configuration: config)
            
            do {
                for d in learningData {
                    try csvWriter?.writeLine(of: ["\(d.0)", "\(d.1)"])
                }
            } catch {
                print("unable to write to csv")
            }
        }
        csvStream?.close()
        savingCSV = false
    }
    
    public func showExportView() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sandboxBrowser = SandboxBrowser(initialPath: url)
        UIApplication.shared.keyWindow?.rootViewController?.present(sandboxBrowser, animated: true, completion: nil)
        // note that csv can be exported as we still write data to it
    }
}
