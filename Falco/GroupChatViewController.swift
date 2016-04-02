//
//  GroupChatViewController.swift
//  Falco
//
//  Created by Jing Yin Ong on 2/4/16.
//  Copyright © 2016 nus.cs3217.group04. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import JSQMessagesViewController

class GroupChatViewController: JSQMessagesViewController {
    // to be set before the controller loads
    var groupName: String!
    var groupID: String!
    var user: User!
    
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var usersTypingQuery: FQuery!
    let messagesRef = Firebase(url: "https://amber-torch-6648.firebaseio.com/messages")
    let typingRef = Firebase(url: "https://amber-torch-6648.firebaseio.com/typing")
    var groupMsgsRef: Firebase!
    var groupTypingRef: Firebase!
    var userIsTypingRef: Firebase!
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // testing purposes
        groupName = "test chat"
        groupID = "testChat"
        user = User(uid: "jy", name: "Jing")
        
        title = groupName
        senderId = user.identifier
        senderDisplayName = user.name
        groupMsgsRef = messagesRef.childByAppendingPath(groupID)
        groupTypingRef = typingRef.childByAppendingPath(groupID)
        userIsTypingRef = groupTypingRef.childByAppendingPath(user.identifier)
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero//(width: 2, height: 2)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero//(width: 2, height: 2)
        setMessageViews()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
            return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
            let message = messages[indexPath.item]
            if message.senderId == senderId {   //local user
                return outgoingBubbleImageView
            } else {
                return incomingBubbleImageView
            }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
            
            let message = messages[indexPath.item]
            
            if message.senderId == senderId {
                cell.textView!.textColor = UIColor.whiteColor()
            } else {
                cell.textView!.textColor = UIColor.blackColor()
            }
            
            return cell
    }

    /// Displays avatar of users
    override func collectionView(collectionView: JSQMessagesCollectionView!,
        avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
            return nil
           // JSQMessagesAvatarImageFactory.avatarImageWithImage(<#T##image: UIImage!##UIImage!#>, diameter: <#T##UInt#>)
    }
    
    /// Sets the bubble view for incoming and outgoing messages
    private func setMessageViews() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    /// Adds a message
    func addMessage(userID: String, userName: String, text: String) {
        let message = JSQMessage(senderId: userID, displayName: userName, text: text)
        messages.append(message)
    }
    
    /// Action when "Send" button is selected
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!,
        senderDisplayName: String!, date: NSDate!) {
            let itemRef = groupMsgsRef.childByAutoId()
            let messageItem = [
                "text": text,
                "senderID": senderId,
                "senderName": senderDisplayName
                //"date": date
            ]
            itemRef.setValue(messageItem)
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            finishSendingMessage()
            isTyping = false
    }
    
    func observeMessages() {
        self.getMessage() { JSQMessage in
            if let message = JSQMessage {
                self.messages.append(message)
                self.finishReceivingMessage()
            }
        }
    }
    
    func getMessage(callback: (JSQMessage?) -> ()) {
        groupMsgsRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            if snapshot.value is NSNull {
                callback(JSQMessage())
                return
            }
            let msgData = snapshot.value as! [String: String]
            let id = msgData["senderID"]
            let text = msgData["text"]
            let name = msgData["senderName"]
            
            callback(JSQMessage(senderId: id, displayName: name, text: text))
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    /// Observe whether other users are typing
    private func observeTyping() {
        userIsTypingRef = groupTypingRef.childByAppendingPath(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = groupTypingRef.queryOrderedByValue().queryEqualToValue(true)
        
        usersTypingQuery.observeEventType(.Value) { (data: FDataSnapshot!) in
            if data.childrenCount == 1 && self.isTyping {   //only self is typing
                return
            }
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
        observeTyping()
    }
    
    /// Checks whether user is entering input into the message bar
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        if textView.text != "" {
            isTyping = true
        } else {
            isTyping = false
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
}