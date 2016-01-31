//  Copyright © 2016 Russell Stephens. All rights reserved.
//

import Quick
import Nimble
import Nocilla

@testable import SwiftProtobuf

class ProtobufSpec: QuickSpec {
    
    override class func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }
    
    override class func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().stop()
    }
    
    override func spec() {

        let url = NSURL(string: "http://www.reddit.com/.json")!
        let jsonStubPath = NSBundle(forClass: self.dynamicType).pathForResource("reddit", ofType: "json")!
        let jsonStubData = NSData(contentsOfFile: jsonStubPath)!
        
        describe("stubbing") {
            
            it("stubs") {
                stubRequest("GET", url.absoluteString).andReturnRawResponse(jsonStubData)
                let urlData = NSData(contentsOfURL: url)
                expect(urlData).toEventually(equal(jsonStubData))
            }
        }
    }
}