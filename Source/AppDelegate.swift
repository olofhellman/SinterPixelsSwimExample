//
//  AppDelegate.swift
//  SinterPixelsBridge
//
//  Created by Olof Hellman on 7/12/26.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    static var shared: AppDelegate? = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        AppDelegate.shared = self
        let spScript = SPScript()
        Task {
            await spScript.ensurePermissions(bundleId: "com.tomographic.sinterpixels")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    public func doMakeDocument(named name: String?) {
        let spScript = SPScript()
        Task {
            await spScript.makeDocument(named: name)
        }
    }

    public func doMakeGrid(docName: String?) {
        let spScript = SPScript()
        Task {
            await spScript.makeGrid(docName: docName)
        }
    }

    
}

