//
//  DebugUtils.swift
//  SwiftUtils
//
//  Created by Mark Bailey on 10/07/2020.
//  Copyright © 2020 MPD Bailey Technology. All rights reserved.
//

import Foundation

public func mpdbCurrentQueueName() -> String? {
    let name = __dispatch_queue_get_label(nil)
    return String(cString: name, encoding: .utf8)
}

public func mpdbLogCurrentQueueName() {
    print("(MPDB SwiftUtils) Current Queue: \(mpdbCurrentQueueName() ?? "nil")")
}

///https://stackoverflow.com/questions/27556807/swift-pointer-problems-with-mach-task-basic-info/39048651#39048651
public func mpdbReportMemory(tag: String = "") {
    var taskInfo = task_vm_info_data_t()
    var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
    let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
        }
    }
    //Convert from Kb to Mb
    let usedMb = Float(taskInfo.phys_footprint) / 1048576.0
    let totalMb = Float(ProcessInfo.processInfo.physicalMemory) / 1048576.0
    result != KERN_SUCCESS ? print("\(tag) Memory used: ? of \(totalMb)Mb") : print("\(tag) Memory used: \(usedMb) of \(totalMb)MB")
}

public struct Timing {
    private let start = CFAbsoluteTimeGetCurrent()
    public init(){}
    
    public var elapsedSeconds : Double {
        return CFAbsoluteTimeGetCurrent() - start
    }
    
    public func log() {
        print("Time taken: \(elapsedSeconds)s")
    }
}
