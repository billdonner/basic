import XCTest
@testable import basic 

class ChaManTests: XCTestCase {

    var chaMan: ChaMan!
    var playData: PlayData!

//    override func setUp() {
//        super.setUp()
//        // Set up your test data
//        playData = generateTestPlayData()
//        chaMan = ChaMan(playData: playData)
//    }

    override func tearDown() {
        chaMan = nil
        playData = nil
        super.tearDown()
    }

   
}
