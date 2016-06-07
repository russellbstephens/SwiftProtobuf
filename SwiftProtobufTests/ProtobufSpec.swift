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

        let protoStubPath = NSBundle(forClass: self.dynamicType).pathForResource("reddit", ofType: "protobuf")!
        let protoStubData = NSData(contentsOfFile: protoStubPath)!

        stubRequest("GET", url.absoluteString).andReturnRawResponse(jsonStubData)

        describe("building from JSON") {
            
            it("maps to the message definition") {

                do {
                    let data = NSData(contentsOfURL: url)!
                    let reader = try JSONReader.from(data)!
                    let reddit = Reddit.fromReader(reader)
                    expect(reddit.kind).to(equal("Listing"))
                    let firstChild = reddit.data?.children.first
                    expect(firstChild).toNot(beNil())
                    let childData = firstChild?.data
                    expect(childData).toNot(beNil())
                    expect(childData?.title).to(equal("The moon passed between Nasa's Deep Space Climate Observatory and the Earth"))
                    expect(childData?.permalink).to(equal("/r/space/comments/43j2kx/the_moon_passed_between_nasas_deep_space_climate/"))
                } catch {
                    fail()
                }
            }

            it("translates to protobuf") {

                do {
                    let data = NSData(contentsOfURL: url)!
                    let jsonReader = try JSONReader.from(data)!
                    let messageFromJSON = Reddit.fromReader(jsonReader)

                    let protoWriter = try ProtobufWriter.withCapacity(messageFromJSON.sizeInBytes)
                    messageFromJSON.toWriter(protoWriter)

                    let protobufData = try protoWriter.toBuffer()

                    let protoReader = ProtobufReader.from(protobufData)!
                    let messageFromProto = Reddit.fromReader(protoReader)

                    expect(messageFromProto.kind).toNot(beNil())
                    expect(messageFromProto.kind).to(equal("Listing"))
                    let firstChild = messageFromProto.data?.children.first
                    expect(firstChild).toNot(beNil())
                    let childData = firstChild?.data
                    expect(childData).toNot(beNil())
                    expect(childData?.title).to(equal("The moon passed between Nasa's Deep Space Climate Observatory and the Earth"))
                    expect(childData?.permalink).to(equal("/r/space/comments/43j2kx/the_moon_passed_between_nasas_deep_space_climate/"))
                } catch {
                    fail()
                }
            }
        }

        describe("building from Proto") {

            it("maps to the message definition") {
                let reader = ProtobufReader.from(protoStubData)!
                let reddit = Reddit.fromReader(reader)
                expect(reddit.kind).to(equal("Listing"))
                let firstChild = reddit.data?.children.first
                expect(firstChild).toNot(beNil())
                let childData = firstChild?.data
                expect(childData).toNot(beNil())
                expect(childData?.title).to(equal("The moon passed between Nasa's Deep Space Climate Observatory and the Earth"))
                expect(childData?.permalink).to(equal("/r/space/comments/43j2kx/the_moon_passed_between_nasas_deep_space_climate/"))
            }

            it("translates to json") {

                do {
                    let reader = ProtobufReader.from(protoStubData)!
                    let messageFromProto = Reddit.fromReader(reader)

                    let protoWriter = try JSONWriter.withCapacity(messageFromProto.sizeInBytes)
                    messageFromProto.toWriter(protoWriter)

                    let protobufData = try protoWriter.toBuffer()

                    let jsonReader = try JSONReader.from(protobufData)!
                    let message = Reddit.fromReader(jsonReader)

                    expect(message.kind).toNot(beNil())
                    expect(message.kind).to(equal("Listing"))
                    let firstChild = message.data?.children.first
                    expect(firstChild).toNot(beNil())
                    let childData = firstChild?.data
                    expect(childData).toNot(beNil())
                    expect(childData?.title).to(equal("The moon passed between Nasa's Deep Space Climate Observatory and the Earth"))
                    expect(childData?.permalink).to(equal("/r/space/comments/43j2kx/the_moon_passed_between_nasas_deep_space_climate/"))
                } catch {
                    fail()
                }
            }
        }
    }
}