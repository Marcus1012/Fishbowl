//
//  Connection.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 6/11/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import AEXML
import Foundation
import SwiftyJSON
import SVProgressHUD
import CocoaAsyncSocket
import ObjectMapper


typealias ResponseCallback  = (FbTicket, FbResponse) -> Void
typealias ResponseListCallback = (String) -> Void
typealias AsyncSocketCallback = (Int, NSData?) -> Void  // Send "tag" num & NSData (if any)
typealias AsyncSocketCallbackInt32 = (Int, Int32) -> Void  // Send "tag" num & Int32 value
typealias AsyncSocketCallbackString = (Int, String) -> Void  // Send "tag" num & String value


class ResponseDelegate {
    var responseName: String!
    var responseCallback: ResponseCallback!
    
    init(name:String, callback: ResponseCallback) {
        responseName = name
        responseCallback = callback
    }
}

class RequestListItem: ResponseDelegate {
    var request: FbMessageRequest!
    
    required init (request:FbMessageRequest, responseName:String, handler: ResponseCallback) {
        super.init(name: responseName, callback: handler)
        self.request = request
    }
}


class Connection: NSObject, NSStreamDelegate {
    
    var delegateList = [String: ResponseDelegate]()
    var callbackDelegateList = [String: ResponseDelegate]()
    var delegate:FBResponseDelegate? = nil
    var host:String = ""
    var port:Int = 0
    var inputStream: NSInputStream?
    var outputOpen = false
    var inputOpen = false
#if DEBUG
    var debugConsole = FbSocket(host: "localhost", port: 4000)
#endif
    var asyncSocket = FbSocket()
    var test = false
    private var maxRetries = 3
    private var retryCount = 0

    // MARK: - New Socket Methods
    func setConnectionDetails(host: String, port: Int) {
        self.host = host
        self.port = port
        asyncSocket.setConnection(host, port: UInt16(port))
    }
    
    private func doServerRequest(request: AnyObject, completion: ResponseCallback ) {
        let fbTicket = FbTicket(key: "", userId: 0)
        let fbResponse = FbResponse()
        let reqJson = JSONSerializer.toJson(request)
#if DEBUG
        debugConsole.sendDebug(reqJson)
        
        if test {
            print("testing DEBUG read")
            debugConsole.readString(70, completion: { (tag, response) in
                print("READ DEBUG tag: \(tag): response: \(response)")
            })
            test = false
        }
#endif
        
        asyncSocket.sendJsonRequest(reqJson, completion: { (tag, nsData) in
            if tag < 0 {
                fbResponse.setStatus(1014) // Unable to establish network connection
                completion(fbTicket, fbResponse)
            } else {
                self.asyncSocket.readJsonResponse({ (response) in
                    self.asyncSocket.disconnect()
#if DEBUG
                    self.debugConsole.sendDebug(response)
#endif
                    if let data = response.dataUsingEncoding(NSUTF8StringEncoding) {
                        let jsonResponse = JSON(data: data)
                        if jsonResponse != nil {
                            if let fbiJson: JSON = jsonResponse["FbiJson"] {
                                let ticketJson:JSON = fbiJson["Ticket"]
                                fbTicket.setJson(ticketJson)
                                fbResponse.initializeWithJson(fbiJson["FbiMsgsRs"])
                            }
                            if fbResponse.getStatus() == 1130 { // invalid ticket... try to re-login
                                self.ReLoginRequest(request as! FbMessageRequest, completion: completion)
                            } else { // good reponse... send to callback
                                g_apiKey = fbTicket.getKey()
                                g_userId = fbTicket.getUserId()
                                self.retryCount = 0
                                completion(fbTicket, fbResponse)
                            }
                        } else {
                            //assert(false, "XML response? = \(response.characters.count): \(response)")
                            self.retryCount = 0
                            fbResponse.setStatus(1001) // Unknown message received
                            completion(fbTicket, fbResponse)
                        }
                    }
                })
            }
        })

    }
    
    private func ReLoginRequest(curRequest: FbMessageRequest, completion: ResponseCallback) {
        if self.retryCount < self.maxRetries {
            self.retryCount += 1
            self.sendLoginRequest({ (ticket, response) in
                if self.ReLoginResponse(ticket, response: response) {
                    g_apiKey = ticket.getKey()
                    g_userId = ticket.getUserId()
                    curRequest.FbiJson.Ticket.setKey(g_apiKey)
                    self.doServerRequest(curRequest, completion: completion)
                }
            })
        }
    }
    
    private func ReLoginResponse(ticket: FbTicket, response: FbResponse) -> Bool {
        if response.isValid(Constants.Response.login) {
            let data = String(response.getJson())
            if let loginResponse = Mapper<FbLoginResponse>().map(data) {
                g_moduleAccess = loginResponse.ModuleAccess.copyWithZone(nil) as! FbModuleAccess
                return true
            }
        }
        return false
    }

    // Async call
    func connectAndSendRequest(request: AnyObject, message:String?="Completed", status:String?=nil, handler: ResponseCallback) {
        let msgStatus:String = (status != nil) ? status! : "Processing request..."
        if message != nil && message?.characters.count > 0 {
            SVProgressHUD.showWithStatus(msgStatus)
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.doServerRequest(request, completion: { (fbTicket, fbResponse) in
                dispatch_async(dispatch_get_main_queue(), {
                    if let msg = message {
                        if msg.characters.count > 0 {
                            // only show hud message if its not an empty string
                            SVProgressHUD.showInfoWithStatus(msg)
                        } else {
                            SVProgressHUD.dismiss()
                        }
                    } else {
                        SVProgressHUD.showSuccessWithStatus("Request finished")
                    }
                    handler(fbTicket, fbResponse)
                })
            })
        }
    }
    
    func sendLoginRequest(handler: ResponseCallback) {
        let fbMessageRequest = FbMessageRequest(
            key: "",
            requestObj: FbiLoginRequest(username: g_username, password: g_password)
        )
        connectAndSendRequest(fbMessageRequest, message: "") { (ticket, response) in
            handler(ticket, response)
        }
    }
    
    private func setCallbackDelegate(responseName: String, callback:ResponseCallback) {
        let newDelegate = ResponseDelegate(name: responseName, callback: callback)
        callbackDelegateList[responseName] = newDelegate
    }
    
    /*
        Callers can register a new delegate/callback function for a given response name.
        Only one handler per response name is allowed.
    */
    func addResponseDelegate(responseName: String, callback:ResponseCallback)
    {
        let newDelegate = ResponseDelegate(name: responseName, callback: callback)
        delegateList[responseName] = newDelegate
    }
    
    /*
        Unregister a response delegate/callback function for the given response name.
    */
    func removeResponseDelegate(responseName: String)
    {
        delegateList[responseName] = nil
    }
    
    /*
       Send status back to the connection delegate
    */
    private func dispatchStatus(status: NSStreamStatus)
    {
        if delegate != nil {
            delegate?.receivedServerStatus(status)
        }
    }
    
    /*
        Send errors back to the connection delegate
    */
    private func dispatchError(error:NSError)
    {
        if delegate != nil {
            delegate?.receivedServerError(error)
        }
    }
    
    private func dispatchResponse(response:String, length: Int32)
    {
        if let data = response.dataUsingEncoding(NSUTF8StringEncoding) {
            let jsonResponse = JSON(data: data)
            if jsonResponse != nil {
                dispatchJsonResponse(jsonResponse)
                return
            } else {
                // we may have an XML response...
                let data = response.dataUsingEncoding(NSUTF8StringEncoding)
                do {
                    let xmlDoc = try AEXMLDocument(xmlData: data!)
                    let statusCode = Int(xmlDoc.root["FbiMsgsRs"].attributes["statusCode"]!)
                    //let statusTicket = xmlDoc.root["Ticket"]["Key"].value
                    let message = getFBStatusMessage(statusCode!)

                    // Create NSError object and dispatch to the delegate...
                    let userInfo: [NSObject : AnyObject] = [
                        NSLocalizedDescriptionKey :  NSLocalizedString("Unauthorized", value: message, comment: ""),
                    ]
                    let err = NSError(domain: "FishbowlServerErrorDomain", code: statusCode!, userInfo: userInfo)
                    dispatchError(err)

                } catch {
                    assert(false, "XML Parse Error: \(error)")
                }
                
            }
        }
    }
    
    private func dispatchJsonResponse(json: JSON)
    {
        if let fbiJson: JSON = json["FbiJson"] {
            let ticket = FbTicket(json: fbiJson["Ticket"])
            let response = FbResponse(json: fbiJson["FbiMsgsRs"])
            let responseName = response.getName()
            dispatchDelegate(responseName, ticket: ticket, response: response)
            dispatchCallbackDelegate(responseName, ticket: ticket, response: response)
        }
    }
        
    private func dispatchDelegate(responseName: String, ticket: FbTicket, response: FbResponse)
    {
        if delegateList[responseName] != nil {
            delegateList[responseName]!.responseCallback(ticket, response)
        }
    }

    private func dispatchCallbackDelegate(responseName: String, ticket: FbTicket, response: FbResponse)
    {
        if callbackDelegateList[responseName] != nil {
            callbackDelegateList[responseName]!.responseCallback(ticket, response)
        }
    }
    
}
