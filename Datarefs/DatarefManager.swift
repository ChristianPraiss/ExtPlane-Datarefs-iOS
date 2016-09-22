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
     Asks the **DatarefManagerAdapter** to use the provided callbacks
     
     - parameter onRead: Call this closure when a new line of data was read
     - parameter onConnection: Call this closure when connection is established
     - parameter onDisconnection: Call this closure when connection is lost or manually disconnected
     */
    func register(onRead: (Data) -> Void, onConnection: () -> Void, onDisconnection: (Error?) -> Void)
}

public class DatarefManager {
    
    /// The frequency at which to receive updates (higher hz means less frequent updates)
    public enum DatarefManagerUpdateInterval: String {
        case hz60 = "0.6"
        case hz30 = "0.33"
        case hz10 = "0.1"
    }
    
    // MARK: Public API

    /**
     Initializes a new **DatarefManager** which uses the passed **DatarefManagerAdapter** to communicate with the simulator
     
     - parameter adapter: The **DatarefManagerAdapter** to use for network communication
     - parameter updateInterval: The **DatarefManagerUpdateInterval** at which to update `(optional)`
     - returns: Returns the new instance
     */
    public init(adapter: DatarefManagerAdapter, updateInterval: DatarefManagerUpdateInterval = .hz30) {
        self.adapter = adapter
        self.updateInterval = updateInterval
        
        self.adapter.register(onRead: { (data) in
            _onRead(data: data)
            }, onConnection: { 
                _onConnection()
            }) { (error) in
                _onError(error: error)
        }
    }
    
    /**
     Registers a new **Dataref** for observation
     
     - parameter dataref: The **Dataref** to subscribe to
     - parameter callback: Called if an error occurs
     */
    public func register(dataref: Dataref) {
        pendingDatarefsForRegistration.insert(dataref)
        if datarefBeingRegistered == nil {
            if let dataref = pendingDatarefsForRegistration.first {
            datarefBeingRegistered = dataref
            _register(dataref: dataref)
            }
        }
    }
    
    /**
     Unregisters a new **Dataref** from observation
     
     - parameter dataref: The **Dataref** to unsubscribe
     */
    public func unregister(dataref: Dataref) {
        pendingDatarefsForUnregistration.insert(dataref)
    }
    
    // MARK: Private API
    
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
    
    
    private func _register(dataref: Dataref) {
        let command = ExtPlaneProtocol.Command.sub(dataref: dataref)
        adapter.send(data: command.toString().data(using: String.Encoding.utf8)!)
    }
    
    private func _onRead(data: Data) {
        guard let string = String(data: data, encoding: String.Encoding.utf8) {
            
        }
    }
    
    private func _onConnection() {
        
    }
    
    private func _onError(error: Error?) {
        
    }
}
