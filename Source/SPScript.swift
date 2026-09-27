//
//  SPScript.swift
//  SinterPixelsBridge
//
//  Created by Olof Hellman on 7/12/26.
//

import Carbon
import Foundation
import SinterAppleEvents
import SinterPixelsSwim

public class SPScript {
    public func run() async {
        if let spApp = SPApp() {
            _ = spApp.activate()
            if let firstDoc = spApp.document(atASIndex:1) {
                print("doc: \(firstDoc)  ")
            }
            let props = SAERecord()
            props.setKey(.height, int:1000)
            props.setKey(.width, int:1000)
            if let madeObject = spApp.make(new: SPDocument.self, props: props)
            {
                print("event result: \(String(describing: madeObject)))")
                let pg = PenroseGrid()
                pg.party(on: madeObject)
            }
        }
    }
}
