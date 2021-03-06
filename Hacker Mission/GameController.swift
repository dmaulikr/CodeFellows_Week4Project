//
//  GameController.swift
//  Hacker Mission
//
//  Created by Cameron Klein on 10/27/14.
//  Copyright (c) 2014 Code Fellows. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox.AudioServices

class GameController {
  
  class var sharedInstance : GameController {
    struct Static {
      static let instance : GameController = GameController()
    }
    return Static.instance
  }
  
  var game        : GameSession!  //Authoritative list of players is here at all times.
  var revealVC    : RevealViewController!
  var launchVC    : LaunchViewController!
  var homeVC      : HomeViewController!
  var userInfo    : UserInfo?
  var myUserInfo  : UserInfo!
  var thisPlayer  : Player!
  var peerCount   : Int = 0
  
  var missionOutcomesVotedFor = [Bool]()
  var teamsVotedFor = [[Bool]]()
  var logFor = LogClass()


  var multipeerController = MultiPeerController.sharedInstance
  var imagePackets = [ImagePacket]()
  
  init(){
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    multipeerController.gameController = self
    myUserInfo = appDelegate.defaultUser as UserInfo!
    myUserInfo.userPeerID = multipeerController.peerID.displayName
    self.populateVotingRecord()

  }
  
  func handleEvent(newGameInfo: GameSession) {
    self.game = newGameInfo
    let event = game.currentGameState!
    if homeVC == nil && event != .Start && event != .RevealCharacters {
      logFor.DLog("BAD FUNCTION CALLED")
      let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
      let homeVC = storyboard.instantiateViewControllerWithIdentifier("HOME") as HomeViewController
      
      NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
        UIApplication.sharedApplication().keyWindow?.rootViewController = homeVC
          self.handleEvent(newGameInfo)
        }
      } else {
      
      if NSUserDefaults.standardUserDefaults().boolForKey("vibrationOn") {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
      }
      
      findMe()
      logFor.DLog("GAME CONTROLLER: Received \(event.rawValue) event from Main Brain. Woot.")
      switch event{
      case .Start:
        self.gameStart()
      case .NominatePlayers:
        self.nominatePlayers()
      case .RevealNominations:
        self.revealNominations()
      case .MissionStart:
        self.startMission()
      case .RevealVote:
        self.revealVotes()
      case .BeginMissionOutcome:
        self.beginMissionOutcome()
      case .RevealMissionOutcome:
        self.revealMissionOutcome()
      case .End:
        self.endGame()
      default:
          logFor.DLog("Unknown")
      }
    }
  }
  
  func findMe(){
    for player in game.players {
      if player.peerID == multipeerController.peerID.displayName {
        self.thisPlayer = player
      }
    }
  }
  
  func startLookingForGame(){
    
    multipeerController.startAdvertising()
    
  }
  
  func showLoadingScreen(percentage: Float){
    launchVC.showLoadingBar(percentage)
    logFor.DLog("GAME CONTROLLER: Calling show loading screen")
  }
  
  func gameStart() {
    multipeerController.gameRunning = true
    
    logFor.DLog("GAME CONTROLLER: Got Game Start Message")
    
    //multipeerController.stopAdvertising()
    revealVC = RevealViewController(nibName: "RevealViewController", bundle: NSBundle.mainBundle())
    
    self.launchVC.gameStart(revealVC)
    
  }
  
  func nominatePlayers() {
    self.homeVC.nominatePlayers()
  }
  
  func revealNominations() {
    
    self.homeVC.voteOnProposedTeam()
  }
  
  func revealVotes() {
    self.homeVC.revealVotes()
  }
  
  func startMission() {
    self.homeVC.startMission()
  }
  
  func beginMissionOutcome() {
    self.homeVC.voteOnMissionSuccess()

  }
  
  func revealMissionOutcome() {
    self.homeVC.revealMissionOutcome()
  }
  
  func endGame() {
    
  }

  func updatePeerCount(count : Int) {
    self.peerCount = count
    if launchVC != nil {
        launchVC.updateConnectedPeersLabel(count)
      }
  }
  
  func sendUserInfo () {
    let appDel = UIApplication.sharedApplication().delegate as AppDelegate
    if let thisUser = appDel.defaultUser as UserInfo! {
      thisUser.userPeerID = multipeerController.peerID.displayName
      multipeerController.sendUserInfoToLeadController(thisUser)
    }
  }
  
  func requestLatestGameDataFromMainBrain() {
    let dictionary = NSMutableDictionary()
    dictionary.setValue("gameRequest", forKey: "action")
    dictionary.setValue("nothing", forKey: "value")
    multipeerController.sendInfoToMainBrain(dictionary)
  }

  func sendImagePacket () {
    let appDel = UIApplication.sharedApplication().delegate as AppDelegate
    if let thisUser = appDel.defaultUser as UserInfo! {
      thisUser.userPeerID = multipeerController.peerID.displayName
      let image = thisUser.userImage!
      multipeerController.sendImagePacketToLeadController(image)
    }
  }
  
  func handleImagePackets(imagePackets: [ImagePacket]) {
    self.imagePackets = imagePackets as [ImagePacket]
  }
  
  func populateVotingRecord() {
    
    for i in 0...4 {
      missionOutcomesVotedFor.append(false)
      teamsVotedFor.append([Bool]())
      for j in 0...4 {
        teamsVotedFor[i].append(false)
      }
    }
  }
  
  func reconnectFromDisconnect(GameSession){
    
  }
  
  func resetForNewGame() {
    imagePackets = [ImagePacket]()
    populateVotingRecord()
    peerCount = 0
  }
}


