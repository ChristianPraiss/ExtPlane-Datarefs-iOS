//
//  DatarefsTests.swift
//  DatarefsTests
//
//  Created by Christian Praiss on 21/09/2016.
//  Copyright © 2016 Christian Praiss. All rights reserved.
//

import XCTest
@testable import Datarefs

class DatarefsTests: XCTestCase {
    
    func testDatarefValidation() {
        let validRefs = ["sim/flightmodel/engine/ENGN_thro", "sim/flightmodel/misc/h_ind", "sim/cockpit2/engine/indicators/N1_percent"]
        do {
            for ref in validRefs {
                _ = try Dataref(identifier:ref, type: .int)
            }
        } catch {
            XCTFail("A function throwed that shouldn't have thrown\n\(error)")
        }
        
        let invalidRefs = ["/sim/flightmodel/engine/ENGN_thro", "sim/flight-model/misc/h_ind"]
        for ref in invalidRefs {
            XCTAssertThrowsError(try Dataref(identifier: ref, type: .int))
        }

    }
}
