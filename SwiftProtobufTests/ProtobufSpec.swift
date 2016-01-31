//  Copyright © 2016 Russell Stephens. All rights reserved.
//

import Quick
import Nimble
import Nocilla
import ProtocGenSwift

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
        
        stubRequest("GET", url.absoluteString).andReturnRawResponse(jsonStubData)
        
        describe("building from JSON") {
            
            it("maps to the message definition") {
                let data = NSData(contentsOfURL: url)!
                
                do {
                    let reader = try JSONReader.from(data)!
                    let reddit = Reddit.fromReader(reader)
                    expect(reddit.kind).toNot(beNil())
                } catch {
                    fail()
                }
            }
        }
    }
}