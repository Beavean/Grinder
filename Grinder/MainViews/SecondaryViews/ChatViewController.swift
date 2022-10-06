//
//  ChatViewController.swift
//  Grinder
//
//  Created by Beavean on 01.10.2022.
//

import Foundation
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import Gallery

class ChatViewController: MessagesViewController {
    
    //MARK: - Properties
    
    private var chatID = String()
    private var recipientID = String()
    private var recipientName = String()
    private var mkMessages = [MKMassage]()
    let refreshController = UIRefreshControl()
    let currentUser = MKSender(senderId: FirebaseUser.currentID()!, displayName: FirebaseUser.currentUser()!.username)
    var loadedMessageDictionaries = [Dictionary<String, Any>]()
    var initialLoadCompleted = false
    
    //MARK: - Init
    
    init(chatID: String, recipientID: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatID = chatID
        self.recipientID = recipientID
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        configureLeftBarButton()
        configureMessageCollectionView()
        configureMessageInputBar()
        downloadChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseListener.shared.resetRecentCounter(chatRoomID: chatID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FirebaseListener.shared.resetRecentCounter(chatRoomID: chatID)
    }
    
    //MARK: - Configure
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backButtonPressed))
    }
    
    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshController
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        let button = InputBarButtonItem()
        button.image = UIImage(named: "attach")
        button.setSize(CGSize(width: 30, height: 30), animated: false)
        button.onTouchUpInside { item in
            self.actionAttachMessage()
        }
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    //MARK: - Actions
    
    @objc func backButtonPressed() {
        FirebaseListener.shared.resetRecentCounter(chatRoomID: chatID)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func actionAttachMessage() {
        print("DEBUG: Attaching image")
    }
    
    private func messageSend(text: String?, photo: UIImage?) {
        guard let currentUserID = FirebaseUser.currentID() else { return }
        OutgoingMessage.send(chatID: chatID, text: text, photo: photo, memberIDs: [currentUserID, recipientID])
    }
    
    //MARK: - Download Chats
    
    private func downloadChats() {
        guard let currentID = FirebaseUser.currentID() else { return }
        FirebaseReference(.Messages).document(currentID).collection(chatID).limit(to: 15).order(by: K.date, descending: true).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                self.initialLoadCompleted = true
                return
            }
            self.loadedMessageDictionaries = ((self.dictionaryArrayFromSnapshot(snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: K.date, ascending: true)]) as! [Dictionary<String, Any>]
            print("DEBUG: \(self.loadedMessageDictionaries.count) Messages")
            self.insertMessages()
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
            self.initialLoadCompleted = true
        }
    }
    
    //MARK: - Insert Messages
    
    private func insertMessages() {
        for messageDictionary in loadedMessageDictionaries {
            insertMessage(messageDictionary)
        }
    }
    
    private func insertMessage(_ messageDictionary: Dictionary<String, Any>) {
        let incoming = IncomingMessage(collectionView: self)
        self.mkMessages.insert(incoming.createMessage(messageDictionary: messageDictionary)!, at: 0)
    }
    
    //MARK: - Helpers
    
    private func dictionaryArrayFromSnapshot(_ snapshots: [DocumentSnapshot]) -> [Dictionary<String, Any>] {
        var allMessages = [Dictionary<String, Any>]()
        for snapshot in snapshots {
            guard let snapshotData = snapshot.data() else { return allMessages }
            allMessages.append(snapshotData)
        }
        return allMessages
    }
}

//MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> MessageKit.SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return mkMessages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            let text = MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.darkGray
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) {
            let message = mkMessages[indexPath.section]
            let status = indexPath.section == mkMessages.count - 1 ?  message.status : ""
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.darkGray
            return NSAttributedString(string: status, attributes: [.font: font, .foregroundColor: color])
        }
         return nil
    }
}

//MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("DEBUG: Tapped on image message")
    }
}

//MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.section % 3 == 0 ? 18 : 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar(initials: mkMessages[indexPath.section].senderInitials))
    }
}

//MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        switch detector {
        case .hashtag, .mention:
            return [.foregroundColor: UIColor.blue]
        default:
            return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? MessageDefaults.bubbleColorOutgoing : MessageDefaults.bubbleColorIncoming
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}

//MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                messageSend(text: text, photo: nil)
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}


