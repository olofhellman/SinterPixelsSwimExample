//
//  SPScript.swift
//  SinterPixelsSwimExample
//
//  Created by Olof Hellman on 7/12/26.
//

import AppKit
import Foundation
import SinterAppleEvents
import SinterPixelsSwim

public extension DescType {
    static var coreEventSuite: DescType = DescType(string: "core")
}

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
    
    public func ensureAESendPermission(target: NSAppleEventDescriptor, eventClass: AEEventClass, eventID: AEEventID) async {
        await queue.enqueue {
            let status = AEDeterminePermissionToAutomateTarget(target.aeDesc, eventClass, eventID, true)
            if status != noErr {
                print("Automation explicitly denied by the user or OS. err = \(status)")
            } else if status == noErr {
                print("Automation allowed. Safe to send event.")
            }
        }
    }
    
    public func ensurePermissions(bundleId: String) async {
        let pid = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first?.processIdentifier ?? 0
        let target = NSAppleEventDescriptor(processIdentifier: pid)
        await self.ensureAESendPermission(target: target, eventClass: AEEventClass(kCoreEventClass), eventID: AEEventID(kAEOpenDocuments))
        await self.ensureAESendPermission(target: target, eventClass: AEEventClass(DescType.coreEventSuite), eventID: AEEventID(kAECountElements))
    }
    
    public func getDoc(named docName: String) async -> SPDocument?    {
        guard let spApp = SPApp() else { return nil }

        let existingDocs = await spApp.documents()
        let existingSPDocs = existingDocs.compactMap { $0 as? SPDocument }
        for nthDoc in existingSPDocs {
            let nthDocName = await nthDoc.name
            if nthDocName == docName {
                return nthDoc
            }
        }
        return nil
    }
    
    public func makeDocument(named docName: String?) async {
        let proposedDocName = docName ?? "Untitled"
        let theDoc = await getDoc(named: proposedDocName)
        if theDoc == nil, let spApp = SPApp() {
            let props = SAERecord()
            props.setKey(.height, int:1000)
            props.setKey(.width, int:1000)
            props.setKey(.name, string: proposedDocName)
            _ = await spApp.make(new: SPDocument.self, props: props)
        }
    }
    
    public func makeGrid(docName: String?) async {
        let pg = PenroseGrid()
        let proposedDocName = docName ?? "Untitled"
        if let spDoc = await getDoc(named: proposedDocName) {
            await queue.enqueue {
                Task { @MainActor in
                    await pg.party(on: spDoc)
                }
            }
        }
    }
}
