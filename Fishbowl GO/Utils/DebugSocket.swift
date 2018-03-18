//
//  DebugSocket.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/30/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import CocoaAsyncSocket


class DebugSocket: NSObject, GCDAsyncSocketDelegate {

    private var socket: GCDAsyncSocket!
    private var host: String!
    private var port: UInt16!
    
    convenience init(host: String, port: UInt16) {
        self.init()
        self.host = host
        self.port = port
    }
    
    func setConnection(host: String, port: UInt16) {
        self.host = host
        self.port = port
    }
    
    func send(output:String) {
        debugSend(output)
    }
    
    func socket(sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {

    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?) {

    }
    
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {

    }
    
    private func debugSend(data: String) {
        if socket == nil {
            socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        }
        if !socket.isConnected {
            do {
                try socket.connectToHost(host, onPort: port)
            } catch {
                return
            }
        }
        
        let output = "\n----------------->\n\(data)\n<-----------------\n" as NSString
        let data = output.dataUsingEncoding(NSUTF8StringEncoding)!
        socket.writeData(data, withTimeout: -1, tag: 1)
        socket.disconnectAfterWriting()
    }

}
