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
        
        let protobufPath = NSBundle(forClass: self.dynamicType).pathForResource("reddit", ofType: "protobuf")!
        let protobufData = NSData(contentsOfFile: protobufPath)!

        stubRequest("GET", url.absoluteString).andReturnRawResponse(jsonStubData)
        
        describe("building from JSON") {
            
            it("maps to the message definition") {
                let data = NSData(contentsOfURL: url)!
                
                do {
                    let reader = try JSONReader.from(data)!
                    let reddit = Reddit.fromReader(reader)
                    expect(reddit.kind).to(equal("Listing"))
                    let firstChild = reddit.data?.children.first
                    expect(firstChild).toNot(beNil())
                    let data = firstChild?.data
                    expect(data).toNot(beNil())
                    expect(data?.title).to(equal("The moon passed between Nasa's Deep Space Climate Observatory and the Earth"))
                    expect(data?.permalink).to(equal("/r/space/comments/43j2kx/the_moon_passed_between_nasas_deep_space_climate/"))
                } catch {
                    fail()
                }
            }
        }
        
        describe("building from Protobuf") {
            
            it("maps to the message definition") {
                
                let reader = ProtobufReader.from(protobufData)!
                let reddit = Reddit.fromReader(reader)
                expect(reddit.kind).toNot(beNil())
            }
        }
    }
}