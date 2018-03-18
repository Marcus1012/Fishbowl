//
//  AsyncSocket.swift
//  Fishbowl GO
//
//  Created by Marcus Korpi on 8/30/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import Foundation
import CocoaAsyncSocket


class FbSocket: AsyncSocket {
    var callbackIndex: Int = 0
    var callbackList = [Int: AsyncSocketCallback]()
    var callbackListInt32 = [Int: AsyncSocketCallbackInt32]()
    var callbackListString = [Int: AsyncSocketCallbackString]()
    
    func socket(sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {

    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
        if let callback = callbackListInt32[tag] {
            callbackListInt32[tag] = nil // remove from list

            var valueBE :Int32 = 0
            assert(data.length == sizeof(Int32), "Invalid read size for Int32")
            data.getBytes(&valueBE, length: sizeof(Int32))
            callback(tag, valueBE.bigEndian)
            return
        }
        
        if let callback = callbackListString[tag] {
            callbackListString[tag] = nil // remove from list
            if let dataString = String(data: data, encoding: NSUTF8StringEncoding) {
                callback(tag, dataString)
            } else {
                callback(tag, "")
            }
            return
        }
        
    }
    
    override func socket(sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        super.socket(sock,didWriteDataWithTag: tag)
        if let callback = callbackList[tag] {
            callbackList[tag] = nil // remove from list
            callback(tag, nil)
        }
    }

    override func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?) {
        super.socketDidDisconnect(sock, withError: err)

        if let error = err {
            if error.code > 0 {
                // Call all callbacks with error.
                callAndClearCallbacks(error.code * -1)
                callAndClearCallbacksInt32(error.code * -1)
                callAndClearCallbacksString(error.code * -1)
            }
        }
    }
    
    private func callAndClearCallbacks(error: Int) {
        for (_, callback) in callbackList {
            callback(-1, nil)
        }
        callbackList.removeAll()
    }
    
    private func callAndClearCallbacksInt32(error: Int) {
        for (_, callback) in callbackListInt32 {
            callback(-1, 0)
        }
        callbackListInt32.removeAll()
    }
    
    private func callAndClearCallbacksString(error: Int) {
        for (_, callback) in callbackListString {
            callback(-1, "")
        }
        callbackListString.removeAll()
    }
    
    func sendJsonRequest(data: String, completion: (Int, NSData?) -> Void ) {
        writeInt32(Int32(data.characters.count), completion: { (tag, nsData) in
            if tag < 0 {
                completion(tag, nsData)
            } else {
                self.writeString(data, completion: { (tag, nsData2) in
                    completion(tag, nsData2)
                })
            }
        })
    }
    
    func readJsonResponse(completion: (String) -> Void ) {
        readInt32 { (tag, stringLength) in
            if tag < 0 {
                completion("")
            } else {
                self.readString(stringLength, completion: { (tag, response) in
                    completion(response)
                })
            }
        }
    }
    
    func writeString(data:String, completion: (Int, NSData?) -> Void ) {
        let tag = addCompletionHandler(completion)
        writeString(data, tag: tag)
    }
    
    func readString(length: Int32, completion: (Int, String) -> Void ) {
        let tag = addCompletionHandlerString(completion)
        let buffer = NSMutableData()
        readData(UInt(length), buffer: buffer, tag: tag)
    }

    func readInt32(completion: (Int, Int32) -> Void ) {
        let tag = addCompletionHandlerInt32(completion)
        let buffer = NSMutableData()
        readData(UInt(sizeof(Int32)), buffer: buffer, tag: tag)
    }
    
    func writeInt32(val: Int32, completion: (Int, NSData?) -> Void ) {
        let tag = addCompletionHandler(completion)
        var valueBE :Int32 = val.bigEndian
        let data = NSData(bytes: &valueBE, length: sizeof(Int32))
        writeData(data, tag: tag)
    }

    // for testing
    func writeInt32str(val: Int32, completion: (Int, NSData?) -> Void ) {
        let tag = addCompletionHandler(completion)
        let temp = "-->Int32 value: \(val), tag: \(tag)"
        writeString(temp, tag: tag)
    }
    
    private func getCallbackIndex() -> Int {
        callbackIndex += 1
        if callbackIndex < 0 {
            callbackIndex = 1 // reset if value wraps
        }
        return callbackIndex
    }
    
    private func addCompletionHandler(completion: (Int, NSData?) -> Void ) -> Int {
        let index = getCallbackIndex()
        callbackList[index] = completion
        return index
    }
    
    private func addCompletionHandlerInt32(completion: (Int, Int32) -> Void ) -> Int {
        let index = getCallbackIndex()
        callbackListInt32[index] = completion
        return index
    }
    
    private func addCompletionHandlerString(completion: (Int, String) -> Void ) -> Int {
        let index = getCallbackIndex()
        callbackListString[index] = completion
        return index
    }
}


class AsyncSocket: NSObject, GCDAsyncSocketDelegate {

    private var socket: GCDAsyncSocket!
    private var host: String!
    private var port: UInt16!
    private let timeout: NSTimeInterval = 5.0 // default timeout value
    
    convenience init(host: String, port: UInt16) {
        self.init()
        self.host = host
        self.port = port
    }
    
    func setConnection(host: String, port: UInt16) {
        self.host = host
        self.port = port
    }
    
    func writeString(output:String, tag: Int) {
        let data = output as NSString
        writeData(data.dataUsingEncoding(NSUTF8StringEncoding)!, tag: tag)
    }
    
    func sendDebug(data: String) {
        let output = "\n----------------->\n\(data)\n<-----------------\n" as NSString
        let data = output.dataUsingEncoding(NSUTF8StringEncoding)!
        writeData(data)
    }
    
    func socket(sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {

    }
    
    func socketDidDisconnect(sock: GCDAsyncSocket, withError err: NSError?) {
        if err != nil {
            //print("Disconnect with error: \(error.localizedDescription), number: \(error.code)")
        }
    }
    
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        //print("+Connected to host: \(host):\(port)")
    }
    
    func socket(sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        return 0 // time to exetend the timeout
    }
    
    func socket(sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: NSTimeInterval, bytesDone length: UInt) -> NSTimeInterval {
        return 0 // time to exetend the timeout
    }
    
    private func writeData(data: NSData, tag: Int = 0) {
        if socket == nil {
            socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        }
        if !socket.isConnected {
            do {
                try socket.connectToHost(host, onPort: port, withTimeout: timeout)
            } catch {
                return
            }
        }
        socket.writeData(data, withTimeout: timeout, tag: tag)
    }
    
    private func readData(length: UInt, buffer: NSMutableData, tag: Int) {
        if socket == nil {
            socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        }
        if !socket.isConnected {
            do {
                try socket.connectToHost(host, onPort: port, withTimeout: timeout)
            } catch {
                return
            }
        }
        socket.readDataToLength(length, withTimeout: timeout, buffer: buffer, bufferOffset: 0, tag: tag)
    }
    
    func disconnect() {
        socket.disconnectAfterReadingAndWriting()
    }
}
