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
    let currentUser = MKSender(senderId: FirebaseUser.currentID(), displayName: FirebaseUser.currentUser()!.username)
    var loadedMessageDictionaries = [Dictionary<String, Any>]()
    var gallery: GalleryController!
    var initialLoadCompleted = false
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOldMessages = false
    var typingCounter = 0
    
    //MARK: - Listeners
    
    var newChatListener: ListenerRegistration?
    var typingListener: ListenerRegistration?
    var updateChatListener: ListenerRegistration?
    
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
        setChatTitle()
        createTypingObserver()
        configureLeftBarButton()
        configureMessageCollectionView()
        configureMessageInputBar()
        listenForReadStatusChange()
        downloadChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirebaseListener.shared.resetRecentCounter(chatRoomID: chatID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeListeners()
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
    
    private func setChatTitle() {
        self.title = recipientName
    }
    
    //MARK: - Actions
    
    @objc func backButtonPressed() {
        FirebaseListener.shared.resetRecentCounter(chatRoomID: chatID)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func actionAttachMessage() {
        messageInputBar.inputTextView.resignFirstResponder()
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhoto = UIAlertAction(title: "Camera", style: .default) { alert in
            self.showImageGallery(camera: true)
        }
        let sharePhoto = UIAlertAction(title: "PhotoLibrary", style: .default) { alert in
            self.showImageGallery(camera: false)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true)
    }
    
    private func messageSend(text: String?, photo: UIImage?) {
        OutgoingMessage.send(chatID: chatID, text: text, photo: photo, memberIDs: [FirebaseUser.currentID(), recipientID])
    }
    
    //MARK: - Download Chats
    
    private func downloadChats() {
        FirebaseReference(.Messages).document(FirebaseUser.currentID()).collection(chatID).limit(to: 15).order(by: K.date, descending: true).getDocuments { snapshot, error in
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
            self.getOldMessagesInBackground()
            self.listenForNewChats()
        }
    }
    
    private func listenForNewChats() {
        newChatListener = FirebaseReference(.Messages).document(FirebaseUser.currentID()).collection(chatID).whereField(K.date, isGreaterThan: lastMessageDate()).addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { return }
            if !snapshot.isEmpty {
                for change in snapshot.documentChanges {
                    if change.type == .added {
                        self.insertMessage(change.document.data())
                        DispatchQueue.main.async {
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToLastItem()
                        }
                    }
                }
            }
        })
    }
    
    private func getOldMessagesInBackground() {
        if loadedMessageDictionaries.count > K.numberOfMessagesToLoad {
            FirebaseReference(.Messages).document(FirebaseUser.currentID()).collection(chatID).whereField(K.date, isLessThan: firstMessageDate()).getDocuments { snapshot, error in
                guard let snapshot = snapshot else { return }
                self.loadedMessageDictionaries = ((self.dictionaryArrayFromSnapshot(snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: K.date, ascending: true)]) as! [Dictionary<String, Any>] + self.loadedMessageDictionaries
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                }
                self.maxMessageNumber = self.loadedMessageDictionaries.count - self.displayingMessagesCount - 1
                self.minMessageNumber = self.maxMessageNumber - K.numberOfMessagesToLoad
            }
        }
    }
    
    private func listenForReadStatusChange() {
        updateChatListener = FirebaseReference(.Messages).document(FirebaseUser.currentID()).collection(chatID).addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { return }
            if !snapshot.isEmpty {
                snapshot.documentChanges.forEach { change in
                    if change.type == .modified {
                        self.updateMessage(change.document.data())
                    }
                }
            }
        })
    }
    
    private func updateMessage(_ messageDictionary: Dictionary<String, Any>) {
        for index in 0 ..< mkMessages.count {
            let tempMessage = mkMessages[index]
            if messageDictionary[K.objectID] as! String == tempMessage.messageId {
                mkMessages[index].status = messageDictionary[K.status] as? String ?? K.sent
                if mkMessages[index].status == K.read {
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: - Insert Messages
    
    private func insertMessages() {
        maxMessageNumber = loadedMessageDictionaries.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - K.numberOfMessagesToLoad
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in minMessageNumber ..< maxMessageNumber {
            let messageDictionary = loadedMessageDictionaries[i]
            insertMessage(messageDictionary)
            displayingMessagesCount += 1
        }
    }
    
    private func insertMessage(_ messageDictionary: Dictionary<String, Any>) {
        markMessageAsRead(messageDictionary)
        let incoming = IncomingMessage(collectionView: self)
        self.mkMessages.append(incoming.createMessage(messageDictionary: messageDictionary)!)
    }
    
    private func insertOldMessage(_ messageDictionary: Dictionary<String, Any>) {
        let incoming = IncomingMessage(collectionView: self)
        self.mkMessages.insert(incoming.createMessage(messageDictionary: messageDictionary)!, at: 0)
    }
    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        if loadOldMessages {
            maxMessageNumber = minNumber - 1
            minMessageNumber = maxMessageNumber - K.numberOfMessagesToLoad
        }
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            let messageDictionary = loadedMessageDictionaries[i]
            insertOldMessage(messageDictionary)
            displayingMessagesCount += 1
        }
        loadOldMessages = true
    }
    
    private func markMessageAsRead(_ messageDictionary: Dictionary<String, Any>) {
        if messageDictionary[K.senderID] as? String != FirebaseUser.currentID() {
            OutgoingMessage.updateMessage(withID: messageDictionary[K.objectID] as! String, chatRoomID: chatID, memberIDs: [FirebaseUser.currentID(), recipientID])
        }
    }
    
    private func removeListeners() {
        if let newChatListener = newChatListener {
            newChatListener.remove()
        }
        if let typingListener = typingListener {
            typingListener.remove()
        }
        if let updateChatListener = updateChatListener {
            updateChatListener.remove()
        }
    }
    
    //MARK: - UIScrollViewdelegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            if displayingMessagesCount <  loadedMessageDictionaries.count {
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshController.endRefreshing()
        }
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
    
    private func lastMessageDate() -> Date {
        let lastMessageDate = (loadedMessageDictionaries.last?[K.date] as? Timestamp)?.dateValue() ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    private func firstMessageDate() -> Date {
        let firstMessageDate = (loadedMessageDictionaries.first?[K.date] as? Timestamp)?.dateValue() ?? Date()
        return Calendar.current.date(byAdding: .second, value: -1, to: firstMessageDate) ?? firstMessageDate
    }
    
    //MARK: - Typing indicator
    
    private func createTypingObserver() {
        TypingListener.shared.createTypingObserver(chatRoomID: chatID) { isTyping in
            self.setTypingIndicatorViewHidden(!isTyping, animated: false, whilePerforming: nil) { [weak self] success in
                if success, self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToLastItem()
                }
            }
        }
    }
    
    private func typingIndicatorUpdate() {
        typingCounter += 1
        TypingListener.saveTypingCounter(typing: true, chatRoomID: chatID)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.typingCounterStop()
        }
    }
    
    private func typingCounterStop() {
        typingCounter -= 1
        if typingCounter == 0 {
            TypingListener.saveTypingCounter(typing: false, chatRoomID: chatID)
        }
    }
    
    private func isLastSectionVisible() -> Bool {
        guard !mkMessages.isEmpty else {
            return false
        }
        let lastIndexPath = IndexPath(item: 0, section: mkMessages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    //MARK: - Gallery
    
    private func showImageGallery(camera: Bool) {
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        self.present(gallery, animated: true)
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
            let showLoadMore = (indexPath.section == 0) && loadedMessageDictionaries.count > displayingMessagesCount
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.boldSystemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
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
        if indexPath.section % 3 == 0 {
            if indexPath.section == 0 && loadedMessageDictionaries.count > displayingMessagesCount {
                return 40
            }
            return 18
        }
        return 0
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
        if text != "" {
            typingIndicatorUpdate()
        }
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

extension ChatViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        if images.count > 0 {
            images.first!.resolve { image in
                self.messageSend(text: nil, photo: image)
            }
        }
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true)
    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true)
    }
}


