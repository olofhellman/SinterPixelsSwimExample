//
//  SPScript.swift
//  SinterPixelsBridge
//
//  Created by Olof Hellman on 7/12/26.
//

import AppKit
import Foundation
import SinterAppleEvents
import SinterPixelsSwim

/// A modern serial task queue using async/await
actor SerialTaskQueue {
    private var previousTask: Task<Void, Error>?

    /// Enqueues a new asynchronous block to run strictly after the previous one finishes
    func enqueue(_ block: @Sendable @escaping () async throws -> Void) {
        // Capture the previous task to await it inside the new Task block
        previousTask = Task { [previousTask] in
            // Wait for the prior task to finish (ignoring its success/failure state)
            _ = await previousTask?.result
            
            // Execute the current block
            try await block()
        }
    }
}

public class SPScript {
    private let queue = SerialTaskQueue()
    public func ensurePermissions(bundleId: String) async {
        await queue.enqueue {
            let pid = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first?.processIdentifier ?? 0
            let targetTargetAddress = NSAppleEventDescriptor(processIdentifier: pid)
 
            // Check or request permission
            let status = AEDeterminePermissionToAutomateTarget(targetTargetAddress.aeDesc, AEEventClass(kCoreEventClass), AEEventID(kAEOpenDocuments), true)
            if status != noErr {
                print("Automation explicitly denied by the user or OS. err = \(status)")
            } else if status == noErr {
                print("Automation allowed. Safe to send event.")
            }
        }
    }
    
    public func run() async {
        let pg = PenroseGrid()
        await queue.enqueue {
            if let spApp = SPApp() {
                Task { @MainActor in  
                    _ = spApp.activate()
                    if let firstDoc = await spApp.document(atASIndex:1) {
                        print("doc: \(firstDoc)  ")
                    }
                    let props = SAERecord()
                    props.setKey(.height, int:1000)
                    props.setKey(.width, int:1000)
                    if let madeObject = await spApp.make(new: SPDocument.self, props: props)
                    {
                        print("event result: \(String(describing: madeObject)))")
                        await pg.party(on: madeObject)
                    }
                }
            }
        }
    }
}
