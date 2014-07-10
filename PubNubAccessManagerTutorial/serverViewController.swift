//
//  serverViewController.swift
//  PubNubAccessManagerTutorial
//
//  Created by Eric Theis on 7/9/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

import UIKit

class serverViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var myConfig = PNConfiguration(forOrigin: "pubsub.pubnub.com", publishKey: "demo", subscribeKey: "demo", secretKey: nil, authorizationKey: "my_auth_key")
        
        PubNub.setConfiguration(myConfig)
        PubNub.connect()
        
        var myChannels: [PNChannel] = PNChannel.channelsWithNames(["pam", "pam-1", "pam-2", "pam-3", "pam-4"]) as [PNChannel]
        var authKeys = ["my_auth_key", "my_auth_key_1"]
        
        PNObservationCenter.defaultCenter().addClientConnectionStateObserver(self) { (origin: String!, connected: Bool!, error: PNError!) in
            if connected {
                println("OBSERVER: Successful Connection!");
                
                PubNub.auditAccessRightsForChannels(myChannels) { (rights: PNAccessRightsCollection!, error: PNError!) in
                    println("BLOCK: Audit: all channels, \(myChannels))")
                }
                
                PubNub.grantAllAccessRightsForChannel(myChannels[0], forPeriod: 60, client: authKeys[0]) { (rights: PNAccessRightsCollection!, error: PNError!) in
                    println("BLOCK: Grant: r/w to \(myChannels[0]) for auth key for 60 min")
                    PubNub.auditAccessRightsForChannels(myChannels) { (rights: PNAccessRightsCollection!, error: PNError!) in
                        println("BLOCK: Audit: all channels, \(myChannels))")
                    }
                }
            } else if !connected {
                println("OBSERVER: \(error.localizedDescription), Connection Failed!");
            }
        }
        
        PNObservationCenter.defaultCenter().addAccessRightsChangeObserver(self) { (rights: PNAccessRightsCollection!, error: PNError!) in
            if error != nil {
                println("OBSERVER: AccessRights: ERROR: \(error.localizedDescription)")
                println("OBSERVER: AccessRights: ERROR: \(error.localizedFailureReason)")
                println("OBSERVER: AccessRights: ERROR: \(error.localizedRecoveryOptions)")
                println("OBSERVER: AccessRights: ERROR: \(error.localizedRecoverySuggestion)")
            } else {
                println("OBSERVER: AccessRights: Updated Permissions:")
            }
        }
        
        PNObservationCenter.defaultCenter().addAccessRightsAuditObserver(self) { (rights: PNAccessRightsCollection!, error: PNError!) in
            if error != nil {
                println("OBSERVER: AccessRights: ERROR: \(error.localizedDescription)")
                println("OBSERVER: AccessRights: ERROR: \(error.localizedFailureReason)")
                println("OBSERVER: AccessRights: ERROR: \(error.localizedRecoveryOptions)")
                println("OBSERVER: AccessRights: ERROR: \(error.localizedRecoverySuggestion)")
            } else {
                println("OBSERVER: AccessRights: Channel Permissions:")
                println("OBSERVER: Audit: \(rights.accessRightsInformationForAllClientAuthorizationKeys())")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}