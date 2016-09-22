//
//  Dataref.swift
//  IXEG 737 Pedestal
//
//  Created by Christian Praiss on 21/09/2016.
//  Copyright © 2016 Christian Praiss. All rights reserved.
//

import Foundation

/// Defines the value type of a dataref
public enum DatarefType: String {
    case int = "i"
    case float = "f"
    case double = "d"
    case intarray = "ia"
    case floatarray = "fa"
    case base64 = "b"
    case unknown
    
    static let allValues = [int, float, double, intarray, floatarray, base64]
}

public class Dataref: Hashable {
    
    /// The identifier of an X-Plane dataref
    public let identifier: String
    /// The value type of the dataref
    public let type: DatarefType
    /// The accuracy at which to send updated (e.g. 10 means values need to change by +- 10 before an update ist fired)
    public let accuracy: NSNumber?
    /// The current value of the dataref
    public dynamic var value: Any?
    
    /// Initialies a new **Dataref**
    public init(identifier: String, type: DatarefType, accuracy: NSNumber? = nil) throws {
        try identifier.validateDataref()
        self.identifier = identifier
        self.type = type
        self.accuracy = accuracy
    }
    
    public static func ==(lhs: Dataref, rhs: Dataref) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.type == rhs.type
    }

    public var hashValue: Int {
        return self.identifier.hashValue ^ self.type.hashValue
    }
}

/// An error used to indicate invalid datarefs
public enum DatarefValidationError: Error {
    /// The Dataref identifier started with an invalid charatcter
    case invalidStart
    /// The Dataref identifier contains invalid characters
    case invalidCharacters
    /// The Dataref identifier is too short
    case tooShort
}

extension String {
    internal func validateDataref() throws {
        // Allow letters
        var validCharacters = CharacterSet.letters
        // And numbers
        validCharacters = validCharacters.union(CharacterSet.decimalDigits)
        // And separators
        validCharacters.insert(charactersIn: "_/")
        
        guard !self.hasPrefix("/") else  {
            throw DatarefValidationError.invalidStart
        }
        
        let components = self.components(separatedBy: "/")
        guard components.count >= 2 else {
            throw DatarefValidationError.tooShort
        }
        
        let characterSet = CharacterSet(charactersIn: self)
        guard characterSet.isSubset(of: validCharacters) else {
            throw DatarefValidationError.invalidCharacters
        }
    }
}
