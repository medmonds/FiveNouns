//
//  FNUpdateManager.m
//  Five Nouns
//
//  Created by Matthew Edmonds on 9/28/13.
//  Copyright (c) 2013 Matthew Edmonds. All rights reserved.
//

#import "FNUpdateManager.h"
#import "FNNetworkManager.h"
#import "FNBrain.h"

@interface FNUpdateManager ()
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSMutableDictionary *updateIdentifier;
@property (nonatomic, strong) NSMutableArray *updateQueue;
@end

@implementation FNUpdateManager

/********************************************* Notes **********************************************
 
 * handle the model version number for validation
 * send updates
 * receive updates
 * validate updates and react accordingly
    - when updates come in out of order should roll back the queue to the correct state and pass that state and the received update to the brain to apply
 
 
 
 
 
 
 - move didConnectToClient: out of the brain and into here
 - move - (void)handlePeerDisconnectedUpdate:(FNUpdate *)update from brain maybe

 
local brain will receive a request to add a team from the UI.
 the model will be saved off.
 the update will go out to the server and will expect a response update letting it know if the change was accepted or not
 if the next update received is a change accepted update then good
 if the next update received is a change not accepted (don't know why this would happen) then roll it back
 if the next update received is a different change update not a response to the sent update then roll it back
 then apply the received update
 these update requests can be queued and as long as update accepted respones are received in the order in which updates are requested then everything is fine and good
 if i have update requests queued and a update change comes in (not a response) then throw away the queue and roll bck the model and then apply the incoming update
 
 how to validate updates at the server
 will need a way to make sure that the remote before change state matches the server before change state
 passing the whole model is stupid need a better way to capture t                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       he model state how about a version number
 ok so the server will increment its version number when it accepts a request
 the remote brain will increment its version number after it saves its before change state and sends the update(request)
 so when a remote requests a change it will send the requested change along with the version number
 then being optimistic the local brain will apply the change and increment its version number
 this way if two requested changes are on in route the 2nd request will have the version number of the brain that matches with the assumption that the 1st request was accepted
 wait this will fail with simple incrementing b/c a different remote
 lets say remoteA requests a change (with version number 4) and sends another optimistic change right behind it (w/ version number 5) to the server
 just before this remoteB sends a request out (with version number 4)
 the server accepts remoteBs request and Increments its version number to 5
 then remoteA request with version number 5 comes in. the server would see that the number match and accepted it but that would be wrong
 remote a would through out its change 5 bu the brain would process it and send it to everyone else
 this means that the version number should capture the remote that makes the change somehow and not just the remote but the server and they should not make the distinction btwn server and remote b/c server and reomtes can change

 
***************************************************************************************************/

+ (FNUpdateManager *)sharedUpdateManager
{
    static FNUpdateManager *sharedUpdateManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUpdateManager = [[self alloc] init];
    });
    return sharedUpdateManager;
}

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.identifier = [[NSUUID UUID] UUIDString];
    return self;
}

- (NSMutableArray *)updateQueue
{
    if (!_updateQueue) {
        _updateQueue = [[NSMutableArray alloc] init];
    }
    return _updateQueue;
}

- (NSMutableDictionary *)updateIdentifier
{
    if (!_updateIdentifier) {
        _updateIdentifier = [[NSMutableDictionary alloc] init];
        _updateIdentifier[self.identifier] = @(0);
    }
    return _updateIdentifier;
}

- (void)prepareUpdate:(FNUpdate *)update
{
    NSInteger currentUpdateNumber = [self.updateIdentifier[self.identifier] integerValue];
    NSInteger newUpdateNumber = currentUpdateNumber + [self.updateQueue count] + 1;
    NSMutableDictionary *newUpdateIdentifier = [self.updateIdentifier mutableCopy];
    newUpdateIdentifier[self.identifier] = @(newUpdateNumber);
    update.updateIdentifier = newUpdateIdentifier;
    [self.updateQueue addObject:update];
}

- (void)sendUpdate:(FNUpdate *)update
{
    [self prepareUpdate:update];
    NSLog(@"Sent update with type: %d", update.updateType);
    BOOL success = [[FNNetworkManager sharedNetworkManager] sendData:[FNUpdate dataForUpdate:update]];
}

- (void)receiveUpdate:(NSData *)update
{
    FNUpdate *receivedUpdate = [FNUpdate updateForData:update];
    if (!receivedUpdate) return;
    NSLog(@"Received update with type: %d", receivedUpdate.updateType);

    if (![self.updateQueue count]) {
        // the update queue is empty so this update is a remote update - pass it to the brain
        self.updateIdentifier = receivedUpdate.updateIdentifier;
        [self.brain handleUpdate:receivedUpdate];
    } else if ([[self.updateQueue objectAtIndex:0] isEqual:receivedUpdate]) {
        // an update I sent has been returned to me in the proper order
        self.updateIdentifier = receivedUpdate.updateIdentifier;
        [self.updateQueue removeObjectAtIndex:0];
    } else {
        // the update does not match the first object in the update queue
        self.updateIdentifier = receivedUpdate.updateIdentifier;        
        [self.updateQueue enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(FNUpdate *undo, NSUInteger idx, BOOL *stop) {
            if (undo.updateType != FNUpdateTypeEverything) {
                [undo reverseUpdate];
                [self.brain handleUpdate:undo];
            }
        }];
        [self.updateQueue removeAllObjects];
        [self.brain handleUpdate:receivedUpdate];
    }
}

- (BOOL)isUpdateValid:(NSData *)data
{
    // Can change this in the networkManager and here to return an everything update if it fails validiation if it is necessary but it shouldn't be. Or just set on the update that it is not valid and then send it around and then it would be ignored by others and would signal to the one who sent to or something thats not sending unneccessary data to objects I know are going to ignore it
    FNUpdate *update = [FNUpdate updateForData:data];
    __block BOOL alreadyFoundAChange = NO;
    __block BOOL returnValue = NO;
    [update.updateIdentifier enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
        NSInteger difference = [obj integerValue] - [self.updateIdentifier[key] integerValue];
        if (difference == 0) {
            returnValue = YES;
        } else if (difference == 1 && !alreadyFoundAChange) {
            returnValue = YES;
            alreadyFoundAChange = YES;
        } else {
            returnValue = NO;
            *stop = YES;
        }
    }];
    NSLog(@"UPDATE IS VALID: %d", returnValue);
    return returnValue;
}

- (void)didConnectToClient:(NSString *)peerID
{
    FNUpdate *update = [[FNUpdate alloc] init];
    update.updateType = FNUpdateTypeEverything;
    update.valueNew = [self.brain currentGameState];
    update.updateIdentifier = self.updateIdentifier;
    NSLog(@"Sent everything update to peer: %@", peerID);
    [[FNNetworkManager sharedNetworkManager] sendData:[FNUpdate dataForUpdate:update] toClient:peerID];
}

- (void)didDisconnectFromClient:(NSString *)peerID
{
    // the SERVER brain nils out its statuses array then sends a message to all clients that a player was dropped then sends out its gameStatus
    // when the droppedPlayer Update is recieved by a client it nils out its statuses array then sends a status update it then recieves the new statuses and proceeds with everything in the new reset state
//    [self.allStatuses removeAllObjects];
//    [self.allStatuses addObject:self.status];
//    [self sendUpdate:[FNUpdate updateForObject:nil updateType:FNUpdateTypePeerDisconnected valueNew:nil valueOld:peerID]];
//    [self sendUpdate:[FNUpdate updateForObject:nil updateType:FNUpdateTypeStatus valueNew:self.status valueOld:self.status]];
}



@end
