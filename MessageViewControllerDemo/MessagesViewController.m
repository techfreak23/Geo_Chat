//
//  MessagesViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/4/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import "MessagesViewController.h"
#import "UserListViewController.h"


@interface MessagesViewController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableDictionary *fullRoomInfo;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *jsqMessages;

@end

@implementation MessagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [self.roomInfo objectForKey:@"name"];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishSendingWithSuccess:) name:@"didFinishSendingWithSuccess" object:nil];
    
    self.currentUser = [GeoChatManager sharedManager].currentUser;
    self.senderId = (NSString *)self.currentUser.userID;
    self.senderDisplayName = (NSString *)self.currentUser.nickname;
    self.showLoadEarlierMessagesHeader = NO;
    
    NSLog(@"Room info: %@", self.roomInfo);
    
    self.messages = [self.roomInfo objectForKey:@"messages"];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"actions-ellipse"] style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    
    [self createJSQMessages];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showOptions
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Show current users", @"Show room details", @"Leave room", nil];
    actionSheet.tag = 23;
    [actionSheet showInView:self.view];
}

- (void)createJSQMessages
{
    if (!self.jsqMessages) {
        NSLog(@"Initializing JSQ messages...");
        self.jsqMessages = [[NSMutableArray alloc] init];
        
        if (self.messages) {
            for (NSDictionary *tempDict in self.messages) {
                JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[NSString stringWithFormat:@"%@", [tempDict objectForKey:@"user_id"]] senderDisplayName:[tempDict objectForKey:@"user_name"] date:[tempDict objectForKey:@"time"] text:[tempDict objectForKey:@"content"]];
                [self.jsqMessages addObject:message];
        }
    }
        [self.collectionView reloadData];
    }
}



- (void)didFinishSendingWithSuccess:(NSNotification *)notification
{
    NSLog(@"Did finish with success!: %@", notification.description);
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
}

#pragma mark - 

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.jsqMessages.count;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.jsqMessages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    JSQMessage *message = [self.jsqMessages objectAtIndex:indexPath.item];
    
    if ([message.senderId intValue] == [self.senderId intValue]) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    } else {
        return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    }

}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    JSQMessage *message = [self.jsqMessages objectAtIndex:indexPath.item];
    
    if ([message.senderId intValue] == [self.senderId intValue]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *prevMessage = [self.jsqMessages objectAtIndex:indexPath.item - 1];
        if ([prevMessage.senderId intValue] == [message.senderId intValue]) {
            return nil;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message = [self.jsqMessages objectAtIndex:indexPath.item];
    
    NSLog(@"Message at index path %ld message: %@", (long)indexPath.item, message);
    
    if ([message.senderId intValue] == [self.senderId intValue]) {
        cell.textView.textColor = [UIColor whiteColor];
    } else {
        cell.textView.textColor = [UIColor blackColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    JSQMessage *currentMessage = [self.jsqMessages objectAtIndex:indexPath.item];
    if ([currentMessage.senderId intValue] == [self.senderId intValue]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.jsqMessages objectAtIndex:indexPath.item - 1];
        if ([previousMessage.senderId intValue] == [currentMessage.senderId intValue]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - messages view delegate

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Did press send button with button: %@\nmessage: %@\nsenderID: %@\nDisplay Name: %@", button, text, senderId, senderDisplayName);
    NSString *roomID = [self.roomInfo objectForKey:@"id"];
    [[GeoChatManager sharedManager] sendMessageWithText:text forChatRoomID:roomID];
    
    JSQMessage *newMessage = [[JSQMessage alloc] initWithSenderId:[NSString stringWithFormat:@"%@", senderId] senderDisplayName:(NSString *)senderDisplayName date:date text:text];
    
    [self.jsqMessages addObject:newMessage];
}


#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 23) {
        switch (buttonIndex) {
            case 0: {
                NSLog(@"User wants to see the other users");
                
                UserListViewController *controller = [[UserListViewController alloc] initWithNibName:@"UserListViewController" bundle:nil];
                controller.userList = [self.roomInfo objectForKey:@"users"];
                [self.navigationController pushViewController:controller animated:YES];
            }
                break;
                
            case 1:
                NSLog(@"User wants to see the deets");
                break;
                
            case 2: {
                NSLog(@"User wants to leave the room :(");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Leave Room?" message:@"Are you sure you want to leave this room?" delegate:self cancelButtonTitle:@"Never mind" otherButtonTitles:@"Yes", nil];
                [alert show];
            }
                break;
                
            case 3:
                NSLog(@"User is cancelling");
                
            default:
                break;
        }
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"This is the no button...");
            break;
            
        case 1:
            NSLog(@"Leaving room!");
            break;
            
        default:
            break;
    }
}

@end
