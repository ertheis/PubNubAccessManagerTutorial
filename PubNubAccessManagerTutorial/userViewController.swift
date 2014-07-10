//
//  userViewController.swift
//  PubNubAccessManagerTutorial
//
//  Created by Eric Theis on 7/9/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

import UIKit

class userViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var myConfig = PNConfiguration(forOrigin: "pubsub.pubnub.com", publishKey: "pam", subscribeKey: "pam", secretKey: nil, authorizationKey: "my_auth_key")
        
        PubNub.setConfiguration(myConfig)
        PubNub.connect()
        
        var myChannel: PNChannel = PNChannel.channelWithName("pam") as PNChannel
        var authKeys = ["my_auth_key", "my_auth_key_1"]
        
        PNObservationCenter.defaultCenter().addClientConnectionStateObserver(self) { (origin: String!, connected: Bool!, error: PNError!) in
            if connected {
                println("OBSERVER: Successful Connection!");
                PubNub.subscribeOnChannel(myChannel)
            } else if !connected {
                println("OBSERVER: \(error.localizedDescription), Connection Failed!");
            }
        }
        
        PNObservationCenter.defaultCenter().addClientChannelSubscriptionStateObserver(self) { (state: PNSubscriptionProcessState, channels: [AnyObject]!, error: PNError!) in
            switch state {
            case PNSubscriptionProcessState.SubscribedState:
                println("OBSERVER: Subscribed to Channel: \(channels[0])")
                PubNub.sendMessage("Hello Everybody!", toChannel: channels[0] as PNChannel)
            case PNSubscriptionProcessState.NotSubscribedState:
                println("OBSERVER: Not subscribed to Channel: \(channels[0]), Error: \(error)")
            case PNSubscriptionProcessState.WillRestoreState:
                println("OBSERVER: Will re-subscribe to Channel: \(channels[0])")
            case PNSubscriptionProcessState.RestoredState:
                println("OBSERVER: Re-subscribed to Channel: \(channels[0])")
            default:
                println("OBSERVER: Something went wrong :(")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}