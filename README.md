# README #

Fishbowl GO for iOS

### What is this repository for? ###

* Quick summary
This is the full code repository for Fishbowl GO for iOS. In addition to the swift code files, there are image resources included as well as some sample request/response objects saved in JSON format.

### How do I get set up? ###

* Summary of set up
* Configuration
    1. Setup XCode
    2. Setup brew
    3. Setup cocoapods via brew (brew instal cocoapods)
    4. Clone project with git
    5. run pod install

* Dependencies
    homebrew (see http://brew.sh/ for installation instructions)
    Cocoapods (install via "brew install cocoapods")
    ncat (install via "brew install nmap" package, which includes ncat, ncat allows the debug_monitor.sh to listen for debugging info on port 4000.  Both sent and received requests are logged to the debug port if desired).
* Cocoapods Dependencies:
See Podfile for a list of the pods that are required for the project.  This is an initial list here:
    1. AEXML - XML parsing engine
    2. CryptoSwift - Crypto lib for generating hashes/md5 sums for server authentication/login.
    3. ObjectMapper - Lib for converting JSON object to Swift objects (and reverse)
    4. PMJSON
    5. SwiftSignatureView - Lib for getting finger-drawn signature from screen.
    6. SwiftyJSON - another JSON manipulation library
    7. DatePickerDialog
    8. MMMarkdown
    9. SVProgressHud

* Database configuration
* Deployment instructions

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact
