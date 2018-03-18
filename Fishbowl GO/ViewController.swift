//
//  ViewController.swift
//  Fishbowl Go-Test
//
//  Created by Marcus Korpi on 4/20/16.
//  Copyright © 2016 RPM Consulting. All rights reserved.
//

import UIKit
import LocalAuthentication
import CoreData
import Foundation
import SwiftyJSON
import ObjectMapper
import SVProgressHUD


var serverHost = Constants.defaultServerHost
var serverPort :Int = Constants.defaultServerPort

var moduleSettings = ModuleSettings()
var connectionFishbowl = Connection()

var g_apiKey: String = ""
var g_userId: Int = 0
var g_debug: Bool = false
var g_compatibility = Compatibility()
var g_pluginSettings = PluginSettings()
var g_moduleAccess = FbModuleAccess()
let g_alertSytle = UIAlertControllerStyle.ActionSheet // Could be .Alert as well
let g_maxImageDimension: CGFloat = 1024.0 // Used to down-scale images if needed.
var g_carrierList = [String]()
var g_username: String = ""
var g_password: String = ""
var g_install_id: String = ""
var g_serverVersion: String = ""
var g_requiredVersion: Int = Constants.defaultMajorVersion // default required major version number

// Cached lists...
var locationCache = LocationCache()
var g_partCache = SwiftCache(name: "parts", expiresIn: -1)

class ViewController: UIViewController, UITextFieldDelegate {

    var inputStream: NSInputStream?
    var outputStream: NSOutputStream?
    var outputStreamReady :Bool = false
    var activityIndicator : ActivityIndicatorWithText?
    
    @IBOutlet var host: UITextField!
    @IBOutlet var port: UITextField!
    @IBOutlet var btnFishbowlLogin: UIButton!
    @IBOutlet var labelStatus: UILabel!
    @IBOutlet var switchDebug: UISwitch!
    @IBOutlet weak var headerNavItem: UINavigationItem!
    
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var checkRememberLogin: CheckBox!
    
    @IBOutlet var navBar: UINavigationBar!
    
    // MARK: - IBActions
    @IBAction func btnRememberLogin(sender: AnyObject) {
        checkRememberLogin.isChecked = !checkRememberLogin.isChecked
    }

    @IBAction func btnFishbowlLogin(sender: AnyObject) {
        serverHost = host.text!
        serverPort = Int(port.text!)!
        connectionFishbowl.setConnectionDetails(serverHost, port: serverPort)
        activityIndicator = ActivityIndicatorWithText(text: "Logging in...")
        self.view.addSubview(activityIndicator!)
        self.view.backgroundColor = UIColor.grayColor()

        saveUserSettings()
        /*
        doVersioncheck { (Void) in
            self.sendLoginRequest()
        }
        */
        sendLoginRequest()
    }
    
    @IBAction func switchDebugChanged(sender: AnyObject) {
        g_debug = switchDebug.on
    }

    // MARK: - Response Handlers
    func LoginResponse(ticket: FbTicket, response: FbResponse)
    {
        if response.isValid(Constants.Response.login) { // success?
            let data = String(response.getJson())
            guard let loginResponse = Mapper<FbLoginResponse>().map(data) else {
                LoginError(response)
                return
            }
            g_moduleAccess = loginResponse.ModuleAccess.copyWithZone(nil) as! FbModuleAccess
            if serverVersionCompatible(loginResponse) {
                sendPluginDataRequest()
            } else {
                let version = loginResponse.ServerVersion
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator?.removeFromSuperview()
                    invokeAlertMessage("Login Error", msgBody: "Incompatible server version: \(version).\nPlease upgrade your Fishbowl server", delegate: self)
                })

            }
        } else {
            LoginError(response)
        }
    }
    
    private func LoginError(response: FbResponse) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator?.removeFromSuperview()
            invokeAlertMessage("Login Error", msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        })
    }
    
    private func serverVersionCompatible(loginInfo: FbLoginResponse?) -> Bool {
        if let login = loginInfo {
            g_serverVersion = login.ServerVersion
            let info = login.getServerVerionInfo()
            if Int(info[0]) >= g_requiredVersion {
                return true
            }
        }
        return false
    }
    
    private func CarrierResponse(ticket: FbTicket, response: FbResponse)
    {
        if response.isValid(Constants.Response.carrierList) { // success?
            let data = String(response.getJson())
            if let carriers = Mapper<FbCarriers>().map(data) {
                g_carrierList = carriers.names
            }
        } else {
            invokeAlertMessage("Carrier Error", msgBody: getFBStatusMessage(response.getStatus()), delegate: self)
        }
        
        // Chain to UOM cache request
        // UOM
        let uomListRequest = FbMessageRequest (
            key: g_apiKey,
            requestObj: FbiUOMListRequest()
        )
        
        connectionFishbowl.connectAndSendRequest(uomListRequest, message: "") { (ticket, response) in
            self.UomResponse(ticket, response: response)
        }

    }
    
    private func UomResponse(ticket: FbTicket, response: FbResponse)
    {
        var uomItemList = [UInt: FbUom]()
        
        if response.getStatus() == 1000 && response.getName() == Constants.Response.uomList { // success?
            let uomList = response.getJson()["UOM"]
            if uomList.type == .Array {
                for(_, item) in uomList {
                    let data = String(item)
                    if let uomItem = Mapper<FbUom>().map(data) {
                        uomItemList[uomItem.UOMID] = uomItem
                    }
                }
            }
        }
        
        // Chain to Location cache request
        // Location
        let locationListRequest = FbMessageRequest (
            key: g_apiKey,
            requestObj: FbiLocationListRequest()
        )
        
        connectionFishbowl.connectAndSendRequest(locationListRequest, message: "") { (ticket, response) in
            self.LocationResponse(ticket, response: response)
        }

    }
    
    private func LocationResponse(ticket: FbTicket, response: FbResponse)
    {
        if response.isValid(Constants.Response.locationList) {
            let status = response.getJson()["statusCode"].intValue
            if status == 1000 {
                let data = String(response.getJson()["Location"])
                if let locations: Array<FbLocation> = Mapper<FbLocation>().mapArray(data) {
                    locationCache.setLocations(locations)
                }
            }
        }
    }
    
    private func PluginDataResponse(ticket: FbTicket, response: FbResponse)
    {
        if response.isValid(Constants.Response.getPluginData) {
            let data = response.getJson()["PluginData"]
            for (_, object) in data {
                let name = object["Name"].stringValue
                let value = object["Value"].boolValue
                g_pluginSettings.addSetting(name, value: value)
            }
            sendCompatibleRequest()
        }
    }
    
    private func CompatibleResponse(ticket: FbTicket, response: FbResponse)
    {
        if response.isValid(Constants.Response.compatible) { // success?
            // Save the compatibility response so we know what to
            // enable or disable in the app (according to access rights)
            g_compatibility.license = response.getJson()["License"].stringValue
            g_compatibility.compatible = response.getJson()[Constants.Property.compatible].boolValue
            g_compatibility.status = response.getJson()[Constants.Property.statusCode].int!
            sendCachingRequests()
        }
    }

    // MARK: - Server Requests
    private func sendLoginRequest() {
        self.activityIndicator!.text = "Logging in..."
        self.activityIndicator?.show()
        connectionFishbowl.sendLoginRequest { (ticket, response) in
            self.LoginResponse(ticket, response: response)
        }
    }
    
    private func sendPluginDataRequest() {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator!.text = "Getting plugin data"
            self.activityIndicator?.show()
        })

        let fbMessageRequest = FbMessageRequest (
            key: g_apiKey,
            id: g_userId,
            requestObj: FbiPluginDataRequest(pluginName: Constants.defaultPluginName)
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "") { (ticket, response) in
            self.PluginDataResponse(ticket, response: response)
        }
    }
    
    private func sendCompatibleRequest() {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator!.text = "Checking compatibility"
            self.activityIndicator?.show()
        })
        
        let fbMessageRequest = FbMessageRequest (
            key: g_apiKey,
            id: g_userId,
            requestObj: FbiCompatibleRequest(version: "1.0", edition: "amw")
        )
        connectionFishbowl.connectAndSendRequest(fbMessageRequest, message: "") { (ticket, response) in
            self.CompatibleResponse(ticket, response: response)
        }
    }
    
    /*
     Cache is built from multple requests.
     The requests are "serailized" or chained together, so
     the response of each one triggers the request of the next one.
     */
    private func sendCachingRequests() {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator!.text = "Building cache"
            self.activityIndicator?.show()
        })
        
        // Carrier
        let carrierListRequest = FbMessageRequest (
            key: g_apiKey,
            requestObj: FbiCarrierListRequest()
        )

        connectionFishbowl.connectAndSendRequest(carrierListRequest, message: "") { (ticket, response) in
            self.CarrierResponse(ticket, response: response)
        }
        
        var timeDelay: Int64 = 2
        #if DEBUG
            timeDelay = 0
        #endif
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), timeDelay * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.activityIndicator?.removeFromSuperview()
            self.performSegueToMainMenu()
        }
    }
    
    // MARK: - Support Methods
    private func doVersioncheck(completion: (Void) -> Void ) {
        let fishbowlUrl = "https://9znf1m0tjf.execute-api.us-east-1.amazonaws.com/prod/fishbowlGoVersionCheck?uid=\(g_install_id)"
        let myUrl = NSURL(string: fishbowlUrl)
        let request = NSMutableURLRequest(URL:myUrl!)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            // Check for error
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator?.removeFromSuperview()
                    invokeAlertMessage("Login Error", msgBody: "Unable to get version information", delegate: self)
                })
                //g_requiredVersion = 16 // fallback to version 16
            } else {
                /*
                if let returnData = data {
                    let responseString = String(data: returnData, encoding: NSUTF8StringEncoding)
                    //g_requiredVersion = Int(responseString!)!
                }
                */
            }
            completion()
        }
        task.resume()
    }
    
    internal static func resetGlobalItems() {
        g_apiKey = ""
        g_userId = 0

        g_compatibility.reset()
        g_pluginSettings.reset()
        g_carrierList.removeAll()
        g_username = ""
        g_password = ""
        locationCache.reset()
    }
    
    func TouchIdCall() {
        let authContext : LAContext = LAContext()
        var error : NSError?
        
        if authContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            authContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Login to FishbowlGO", reply: {
                (wasSuccessful: Bool, error: NSError?) in
                
                if wasSuccessful {
                    self.btnFishbowlLogin(self)
                } else {
                    self.password.text = ""
                    //self.checkRememberLogin.isChecked = false
                }
                
            })
        }
        
    }
    
    private func performSegueToMainMenu() {
        performSegueWithIdentifier("connect_segue", sender: self)
    }

    func saveNewUser(userName: String, password: String, context: NSManagedObjectContext) {
        let newUser = NSEntityDescription.insertNewObjectForEntityForName("Users", inManagedObjectContext: context)
        newUser.setValue(userName, forKey: "username")
        newUser.setValue(password, forKey: "password")
        
        do {
            try context.save()
        } catch{
            //print("There was a problem trying to save user: \(userName)")
        }
        
    }
    
    private func saveUserSettings() {
        g_username = username.stringValue
        g_password = password.stringValue
        
        let UserDefaults = NSUserDefaults.standardUserDefaults()
        if checkRememberLogin.isChecked {
            UserDefaults.setValue(g_username, forKey: "username")
            UserDefaults.setValue(g_password, forKey: "password")
        } else {
            UserDefaults.setValue("", forKey: "username")
            UserDefaults.setValue("", forKey: "password")
        }
        UserDefaults.setValue(host.text, forKey: "host")
        UserDefaults.setValue(self.port.text, forKey: "port")
        UserDefaults.setValue(checkRememberLogin.isChecked, forKey: "remember")
        UserDefaults.synchronize()
    }
    
    private func loadUserSettings() {
        let UserDefaults = NSUserDefaults.standardUserDefaults()
        if UserDefaults.valueForKey("username") != nil {
            username.text = UserDefaults.valueForKey("username") as? String
        }
        if UserDefaults.valueForKey("password") != nil {
            password.text = UserDefaults.valueForKey("password") as? String
        }
        if UserDefaults.valueForKey("host") != nil {
            host.text = UserDefaults.valueForKey("host") as? String
        } else {
            host.text = Constants.defaultServerHost
        }
        if UserDefaults.valueForKey("port") != nil {
            port.text = UserDefaults.valueForKey("port") as? String
        } else {
            port.text = String(Constants.defaultServerPort)
        }
        if UserDefaults.valueForKey("remember") != nil {
            checkRememberLogin.isChecked = UserDefaults.valueForKey("remember") as! Bool
        } else {
            checkRememberLogin.isChecked = false
        }
        
        // Unique app installation ID..
        if UserDefaults.valueForKey(Constants.Settings.InstallId) != nil {
            g_install_id = (UserDefaults.valueForKey(Constants.Settings.InstallId) as? String)!
        } else {
            g_install_id = NSUUID().UUIDString
            UserDefaults.setValue(g_install_id, forKey: Constants.Settings.InstallId)
        }
    }
    
    // MARK: - Overrides
    override func viewDidAppear(animated: Bool) {
        if !moduleSettings.settingExists(Constants.Module.General, setting: "TouchId") {
            invokeConfirm("Use Touch ID?", message: "Would you like to use Touch ID to login?", okText: "Yes", cancelText: "No", okHandler: yesTouchIdHandler, cancelHandler: noTouchIdHandler, delegate: self)
            
        }
        
        if moduleSettings.loadSetting(Constants.Module.General, setting: "TouchId", defaultValue: false) as! Bool {
            TouchIdCall()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserSettings() // grab user/pass from ns user defaults
        
        // Set the textFieldDelegates
        host.delegate = self
        port.delegate = self
        username.delegate = self
        password.delegate = self
        
        // Setup default hud appearance
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Custom)
        SVProgressHUD.setBackgroundColor(UIColor(red: 0xF7/255, green: 0x8F/255, blue: 0x1E/255, alpha: 0.80)) // FB Orange
        SVProgressHUD.setForegroundColor(UIColor.blackColor())

        // Set the header title to a clickable image...
        let image = UIImage(named: "header_logo_black.png")
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 36))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        imageView.userInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.clickOnButton))
        imageView.addGestureRecognizer(recognizer)
        headerNavItem.titleView = imageView
        //navigationItem.titleView = imageView
    }
    
    @objc private func clickOnButton() {
        performSegueWithIdentifier("segue_login_about", sender: self)
    }
    func yesTouchIdHandler(action:UIAlertAction) {
        moduleSettings.saveSetting(Constants.Module.General, setting: "TouchId", value: true)
        TouchIdCall()
    }
    func noTouchIdHandler(action:UIAlertAction) {
        moduleSettings.saveSetting(Constants.Module.General, setting: "TouchId", value: false)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true) // close keyboard
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
            case host:
                port.becomeFirstResponder()
                break
            case port:
                username.becomeFirstResponder()
                break
            case username:
                password.becomeFirstResponder()
                break
            case password:
                btnFishbowlLogin(self)
                break
            default:
                textField.resignFirstResponder()
        }
        return true
    }

    
}

