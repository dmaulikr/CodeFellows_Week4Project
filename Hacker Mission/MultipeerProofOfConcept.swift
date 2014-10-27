//
//  ViewController.swift
//  MultiPeer Experiment
//
//  Created by Cameron Klein on 10/23/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import MultipeerConnectivity

class MultiPeerController: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
  
  var peerID      : MCPeerID!
  var session     : MCSession!
  var advertiser  : MCNearbyServiceAdvertiser!
  var browser     : MCNearbyServiceBrowser!
  
  let MyServiceType = "cf-hacker"
  
  override init() {
    super.init()
    println("Multipeer Controller Loaded")
    
    peerID  = MCPeerID(displayName: UIDevice.currentDevice().name)
    
    session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
    session.delegate = self
    
    advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: MyServiceType)
    advertiser.delegate = self
    
    browser = MCNearbyServiceBrowser(peer: peerID, serviceType: MyServiceType)
    browser.delegate = self
  }
  
  func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
    println("Got Resource")
  }
  
  func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
    println("Received Data!")
    let text = NSString(data: data, encoding: NSUTF8StringEncoding)
    NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in

    }
  }
  
  func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    println("Received Stream!")
  }
  
  func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
    println("Started Receiving Resource")
  }
  
  func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
    if state == MCSessionState.Connected {
      println("Peer Connected")
    } else if state == MCSessionState.NotConnected {
      println("Peer Stopped Connecting")
    } else if state == MCSessionState.Connecting {
      println("Peer Connecting")
    }
  }
  
  func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
    session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
    session.delegate = self
    println("Got an invitation")
    invitationHandler(true, self.session)
  }
  
  func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
    println("Found peer with id \(peerID)")
    browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 0)
  }
  
  func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
    println("Lost peer!")
  }
  
}



