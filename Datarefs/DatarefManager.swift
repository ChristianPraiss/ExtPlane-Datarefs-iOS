//
//  DatarefManager.swift
//  IXEG 737 Pedestal
//
//  Created by Christian Praiss on 21/09/2016.
//  Copyright © 2016 Christian Praiss. All rights reserved.
//

import UIKit

public protocol DatarefManagerAdapter: class {
    /**
     Asks the **DatarefManagerAdapter** to send a command over the network
     
     - parameter data: The data to send
     - parameter callback: A callback to call in case of an error
     */
    func send(data: Data)
    
    /**
     Asks the **DatarefManagerAdapter** to read new data
     
     - parameter callback: The callback to call when either data was read or an error was encountered
     */
    func read(callback: (Data, Error?) -> Void)
    
    /**
     Asks the **DatarefManagerAdapter** to use the provided callbacks
     
     - parameter onConnection: Call this closure when connection is established
     - parameter onDisconnection: Call this closure when connection is lost or manually disconnected
     */
    func register(onConnection: () -> Void, onDisconnection: (Error?) -> Void)
}

public class DatarefManager {
    
    /// The frequency at which to receive updates (higher hz means less frequent updates)
    public enum DatarefManagerUpdateInterval: String {
        case hz60 = "0.6"
        case hz30 = "0.33"
        case hz10 = "0.1"
    }
    
    /// The **DatarefManagerAdapter** used for communication
    private let adapter: DatarefManagerAdapter
    /// The **DatarefManagerUpdateInterval** to set once connected
    private let updateInterval: DatarefManagerUpdateInterval
    /// The **Dataref**s currently registered
    public private(set) var registeredDatarefs: Set<Dataref> = Set<Dataref>()
    /// The **Dataref**s that still pend registration
    private var pendingDatarefsForRegistration: Set<Dataref> = Set<Dataref>()
    /// The **Dataref**s that pend unregistration
    private var pendingDatarefsForUnregistration: Set<Dataref> = Set<Dataref>()
    /// The **Dataref** waiting to finish registration
    private var datarefBeingRegistered: Dataref?

    /**
     Initializes a new **DatarefManager** which uses the passed **DatarefManagerAdapter** to communicate with the simulator
     
     - parameter adapter: The **DatarefManagerAdapter** to use for network communication
     - parameter updateInterval: The **DatarefManagerUpdateInterval** at which to update `(optional)`
     - returns: Returns the new instance
     */
    public init(adapter: DatarefManagerAdapter, updateInterval: DatarefManagerUpdateInterval = .hz30) {
        self.adapter = adapter
        self.updateInterval = updateInterval
    }
    
    /**
     Registers a new **Dataref** for observation
     
     - parameter dataref: The **Dataref** to subscribe to
     - parameter callback: Called if an error occurs
     */
    public func register(dataref: Dataref) -> Void {
        pendingDatarefsForRegistration.insert(dataref)
        if let dataref = pendingDatarefsForRegistration.first {
            datarefBeingRegistered = dataref
            // sub sim/flightmodel/misc/h_ind 10.0
            var command = "sub \(dataref.identifier)"
            if let acc = dataref.accuracy {
                switch dataref.type {
                case .float, .double:
                    command += " \(String(format:"%.02f", acc.doubleValue))"
                case .int:
                    command += " \(acc.intValue)"
                default: break;
                }
            }
            adapter.send(data: command.data(using: String.Encoding.utf8)!)
        }
    }
    
    /**
     Unregisters a new **Dataref** from observation
     
     - parameter dataref: The **Dataref** to unsubscribe
     */
    public func unregister(dataref: Dataref) {
        pendingDatarefsForUnregistration.insert(dataref)
    }
}
