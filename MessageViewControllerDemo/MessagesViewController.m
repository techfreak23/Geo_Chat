//
//  MessagesViewController.m
//  MessageViewControllerDemo
//
//  Created by Art Sevilla on 12/4/14.
//  Copyright (c) 2014 Art Sevilla. All rights reserved.
//

#import "MessagesViewController.h"
#import "UserListViewController.h"
#import "GeoChatAPIManager.h"

@interface MessagesViewController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSMutableDictionary *fullRoomInfo;
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, strong) NSMutableArray *userList;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *jsqMessages;
@property (nonatomic, strong) NSTimer *refreshTimer;

@end

@implementation MessagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(pollForNewMessages:) userInfo:nil repeats:YES];
    
    self.title = [self.roomInfo objectForKey:@"name"];
    
    self.userInfo = [[GeoChatAPIManager sharedManager] userInfo];
    
    self.senderId = [NSString stringWithFormat:@"%@", [self.userInfo objectForKey:@"id"]];
    self.senderDisplayName = [self.userInfo objectForKey:@"nick_name"];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishSendingWithSuccess:) name:@"didFinishSendingMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPolling:) name:@"didFinishPolling" object:nil];
    
    self.showLoadEarlierMessagesHeader = NO;
    
    self.messages = [[self.roomInfo objectForKey:@"messages"] mutableCopy];
    self.userList = [[self.roomInfo objectForKey:@"users"] mutableCopy];
    
    self.jsqMessages = [@[] mutableCopy];
    [self createJSQMessages];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"actions-ellipse"] style:UIBarButtonItemStylePlain target:self action:@selector(showOptions)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshMessages)];
    [self.navigationItem setRightBarButtonItems:@[menuButton, refreshButton] animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.refreshTimer invalidate];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)showOptions
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Show current users", @"Show room details", @"Leave room", nil];
    actionSheet.tag = 23;
    [actionSheet showInView:self.view];
}

- (void)refreshMessages
{
    if (self.messages.count > 0) {
        [[GeoChatAPIManager sharedManager] fetchNewMessagesForRoom:[self.roomInfo objectForKey:@"id"] messageIndex:[[self.messages lastObject] objectForKey:@"message_index"]];
    }
}

- (void)createJSQMessages
{
    if (self.messages.count > 0) {
        for (NSDictionary *temp in self.messages) {
            JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[NSString stringWithFormat:@"%@", [temp objectForKey:@"user_id"]] senderDisplayName:[temp objectForKey:@"user_name"] date:[temp objectForKey:@"time"] text:[temp objectForKey:@"content"]];
            [self.jsqMessages addObject:message];
        }
    }
}

#pragma mark - notification methods

- (void)didFinishSendingWithSuccess:(NSNotification *)notification
{
    NSDictionary *temp = (NSDictionary *)[notification object];
    [self.messages addObject:temp];
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[temp objectForKey:@"time"] text:[temp objectForKey:@"content"]];
    
    [self.jsqMessages addObject:message];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessageAnimated:YES];
}

- (void)didFinishPolling:(NSNotification *)notification
{
    NSArray *newMessages = (NSArray *)[[notification object] objectForKey:@"messages"];
    
    NSString *userName;
    
    NSLog(@"users in the room: %@", self.userList);
    
    if (newMessages.count > 0) {
        [self.messages addObjectsFromArray:newMessages];
        
        for (NSDictionary *temp in newMessages) {
            NSString *tempID = [NSString stringWithFormat:@"%@", [temp objectForKey:@"user_id"]];
            
            for (NSDictionary *tmp in self.userList) {
                NSString *currentID = [tmp objectForKey:@"id"];
                
                if ([tempID intValue] == [currentID intValue]) {
                    userName = [tmp objectForKey:@"nick_name"];
                }
            }
            
            JSQMessage *newMessage = [[JSQMessage alloc] initWithSenderId:[NSString stringWithFormat:@"%@", [temp objectForKey:@"user_id"]] senderDisplayName:userName date:[temp objectForKey:@"time"] text:[temp objectForKey:@"content"]];
            [self.jsqMessages addObject:newMessage];
        }
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self finishReceivingMessageAnimated:YES];
    }
}

- (void)pollForNewMessages:(NSTimer *)timer
{
    NSLog(@"Timer is firing...");
    if (self.messages.count > 0) {
        NSLog(@"Fetching new messages from timer method...");
        [[GeoChatAPIManager sharedManager] fetchNewMessagesForRoom:[self.roomInfo objectForKey:@"id"] messageIndex:[[self.messages lastObject] objectForKey:@"message_index"]];
    }
}

- (void)checkUserName
{
    
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
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    } else {
        return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.jsqMessages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *prevMessage = [self.jsqMessages objectAtIndex:indexPath.item - 1];
        if ([prevMessage.senderId isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    JSQMessage *message = [self.jsqMessages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
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
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.jsqMessages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *prevMessage = [self.jsqMessages objectAtIndex:indexPath.item - 1];
        if ([prevMessage.senderId isEqualToString:message.senderId]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - messages view delegate

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    NSString *roomID = [self.roomInfo objectForKey:@"id"];
    
    [[GeoChatAPIManager sharedManager] sendMessage:text room:roomID];
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
