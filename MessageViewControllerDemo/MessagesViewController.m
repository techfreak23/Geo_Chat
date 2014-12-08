//
//  MessagesViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/4/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import "MessagesViewController.h"
#import "GeoChatManager.h"

@interface MessagesViewController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableDictionary *fullRoomInfo;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *jsqMessages;
@property (nonatomic, strong) GeoChatUser *currentUser;

@end

@implementation MessagesViewController

- (void)viewDidLoad
{
    NSLog(@"Messages view loading...");
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [_roomInfo objectForKey:@"name"];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    _currentUser = [GeoChatManager sharedManager].currentUser;
    NSLog(@"Current user: %@", _currentUser);
    self.senderId = _currentUser.userID;
    self.senderDisplayName = _currentUser.nickname;
    self.showLoadEarlierMessagesHeader = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishWithRoomInfo:) name:@"didFinishWithRoomObject" object:_fullRoomInfo];
    [[GeoChatManager sharedManager] fetchRoomForID:[_roomInfo objectForKey:@"id"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didFinishWithRoomInfo:(NSNotification *)notification
{
    NSLog(@"Did finish with object: %@", notification.object);
    _fullRoomInfo = notification.object;
    NSLog(@"Full room info: %@", _fullRoomInfo);
    _messages = [_fullRoomInfo objectForKey:@"messages"];
    NSLog(@"Messages: %@", _messages);
    [self createJSQMessages];
}

- (void)createJSQMessages
{
    if (!_jsqMessages) {
        _jsqMessages = [[NSMutableArray alloc] init];
        for (NSDictionary *tempDict in _messages) {
            JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[tempDict objectForKey:@"user_id"] senderDisplayName:_currentUser.nickname date:[tempDict objectForKey:@"time"] text:[tempDict objectForKey:@"content"]];
            [_jsqMessages addObject:message];
        }
        [self.collectionView reloadData];
    }
}

#pragma mark - 

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return _jsqMessages.count;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return [_jsqMessages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    JSQMessage *message = [_jsqMessages objectAtIndex:indexPath.item];
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    }
    
    return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    JSQMessage *message = [_jsqMessages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *prevMessage = [_jsqMessages objectAtIndex:indexPath.item - 1];
        if ([prevMessage.senderId isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message = [_jsqMessages objectAtIndex:indexPath.item];
    
    NSLog(@"Message at index path %ld message: %@", (long)indexPath.item, message);
    
    if ([message.senderId isEqualToString:self.senderId]) {
        cell.textView.textColor = [UIColor blackColor];
    } else {
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    JSQMessage *currentMessage = [_jsqMessages objectAtIndex:indexPath.item];
    if ([currentMessage.senderId isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [_jsqMessages objectAtIndex:indexPath.item - 1];
        if ([previousMessage.senderId isEqualToString:currentMessage.senderId]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - messages view delegate methods

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Did press send button with button: %@\nmessage: %@\nsenderID: %@\nDisplay Name: %@", button, text, senderId, senderDisplayName);
    NSString *roomID = [_roomInfo objectForKey:@"id"];
    [[GeoChatManager sharedManager] sendMessageWithText:text forChatRoomID:roomID];
    
    //JSQMessage *newMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:text];
    
    //[_jsqMessages addObject:newMessage];
    
    [self finishSendingMessage];
}


#pragma mark - action sheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Button index 0");
            break;
            
        case 1:
            NSLog(@"Button index 1");
            break;
            
        case 2:
            NSLog(@"Button index 2");
            
        default:
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

@end
