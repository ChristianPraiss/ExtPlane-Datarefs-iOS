//
//  Constants.swift
//  Datarefs
//
//  Created by Christian Praiss on 21/09/2016.
//  Copyright © 2016 Christian Praiss. All rights reserved.
//

import Foundation

struct ExtPlaneCommandIdentifier {
    static let subscribe = "sub"
    static let unsubscribe = "unsub"
    
    static let setref = "set"
    
    static let changeSetting = "extplane-set"
    
    struct SettingIdentifier {
        static let updateInterval = "update_interval"
    }
    
    static let keyPress = "key"
    static let pressButton = "but"
    static let releaseButton = "rel"
    
    static let commandOnce = "cmd once"
    static let commandBegin = "cmd begin"
    static let commandEnd = "cmd end"
    
    static let disconnect = "disconnect"
}

struct ExtPlaneOutputIdentifier {
    static let connected = "EXTPLANE"
    
    static let valueChanged = "u"
}

struct ExtPlaneProtocol {
    enum Command {
        case sub(dataref: Dataref)
        case unsub(dataref: Dataref)
        case set(dataref: Dataref, value: Any)
        
        case keyTap(keyid: String)
        case buttonPress(buttonid: String)
        case buttonRelease(buttonid: String)
        
        case commandOnce(command: String)
        case commandBegin(command: String)
        case commandEnd(command: String)
        
        case changesetting(setting: String, value: String)
        
        case disconnect
        
        func toString() -> String {
            switch self {
                
            case .sub(let dataref):
                var command = "\(ExtPlaneCommandIdentifier.subscribe) \(dataref.identifier)"
                if let acc = dataref.accuracy {
                    switch dataref.type {
                    case .float, .double:
                        command += " \(String(format:"%.02f", acc.doubleValue))"
                    case .int:
                        command += " \(acc.intValue)"
                    default: break;
                    }
                }
                return command
                
            case .unsub(let dataref):
                return "\(ExtPlaneCommandIdentifier.unsubscribe) \(dataref.identifier)"
                
            case .changesetting(let setting, let value):
                return "\(ExtPlaneCommandIdentifier.changeSetting) \(setting) \(value)"
                
            case .set(let dataref, let value):
                return "\(ExtPlaneCommandIdentifier.setref) \(dataref.identifier) \(value)"
                
            case .disconnect:
                return ExtPlaneCommandIdentifier.disconnect
                
            case .keyTap(let keyid):
                return "\(ExtPlaneCommandIdentifier.keyPress) \(keyid)"
                
            case .buttonPress(let buttonid):
                return "\(ExtPlaneCommandIdentifier.pressButton) \(buttonid)"
                
            case .buttonRelease(let buttonid):
                return "\(ExtPlaneCommandIdentifier.releaseButton) \(buttonid)"
                
            case .commandOnce(let command):
                return "\(ExtPlaneCommandIdentifier.commandOnce) \(command)"
                
            case .commandBegin(let command):
                return "\(ExtPlaneCommandIdentifier.commandBegin) \(command)"
                
            case .commandEnd(let command):
                return "\(ExtPlaneCommandIdentifier.commandEnd) \(command)"
            }
        }
    }
    
    enum OutputValidationError: Error {
        case unknownPrefix
        case commandMissingParts
        case unknownValueType
    }
    
    enum Output {
        case newValue(dataref: Dataref, value: Any)
        case connected
        
        static func fromString(string: String) throws -> Output {
            
            if string == ExtPlaneOutputIdentifier.connected {
                return .connected
            } else if string.hasPrefix(ExtPlaneOutputIdentifier.valueChanged) {
                var valueString = string.substring(from: string.index(string.startIndex, offsetBy: 1))
                var returnType: DatarefType = .unknown
                for type in DatarefType.allValues {
                    if valueString.hasPrefix(type.rawValue) {
                        valueString = valueString.substring(from: string.index(string.startIndex, offsetBy: type.rawValue.distance(from: type.rawValue.startIndex, to: type.rawValue.endIndex)))
                        returnType = type
                    }
                }
                
                guard returnType != .unknown else {
                    throw OutputValidationError.unknownValueType
                }
                
                let parts = valueString.components(separatedBy: " ")
                guard parts.count == 2 else {
                    throw OutputValidationError.commandMissingParts
                }
                
                // Throws if invalid
                try parts[0] .validateDataref()
                
                
            }
            
            throw OutputValidationError.unknownPrefix
        }
    }
}
