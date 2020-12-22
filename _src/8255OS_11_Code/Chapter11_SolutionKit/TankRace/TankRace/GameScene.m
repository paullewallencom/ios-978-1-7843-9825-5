//
//  GameScene.m
//  TankRace
//
//  Created by Rahul on 12/28/14.
//  Copyright (c) 2014 RahulBorawar. All rights reserved.
//

typedef enum {
    kGameStatePlayerToConnect,
    kGameStatePlayerAllotment,
    kGameStatePlaying,
    kGameStateComplete,
} GameState;

typedef enum {
    KNetworkPacketCodePlayerAllotment,
    // More to be added while creating the game
} NetworkPacketCode;

#define kConnectingDevicesText @"Tap to Connect"
#define kGameStartedText       @"Game Started"
#define kConnectedDevicesText  @"Devices Connected"

// Blue is the First and Red is the Second Player
#define kFirstPlayerLabelText  @"You're First Player"
#define kSecondPlayerLabelText @"You're Second Player"

#define kMaxTankPacketSize 1024

#import "GameScene.h"

@interface GameScene() <MCSessionDelegate>
{
    int gameUniqueIdForPlayerAllocation;
}

@property (nonatomic, assign) int gamePacketNumber;

@property (nonatomic, strong) MCSession* gameSession;
@property (nonatomic, strong) MCPeerID* gamePeerID;
@property (nonatomic, strong) NSString* serviceType;
@property (nonatomic, strong) MCAdvertiserAssistant* advertiser;

@property (nonatomic, strong) SKLabelNode* gameInfoLabel;
@property (nonatomic, assign) GameState gameState;

@end

@implementation GameScene

#pragma mark - Overridden Methods

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    gameUniqueIdForPlayerAllocation = arc4random();

    [self addGameInfoLabelWithText:kConnectingDevicesText];
     self.gameState = kGameStatePlayerToConnect;
}

#pragma mark - Public Methods

- (void)startGame
{
    // do nothing
}

- (void)discardSession
{
    self.gameState = kGameStatePlayerToConnect;
    
    self.gameSession = nil;
    self.gamePeerID = nil;
    self.serviceType = nil;
    self.advertiser = nil;
}

#pragma mark - Touch Methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    if (self.gameState == kGameStatePlayerToConnect)
    {
        [self instantiateMCSession];
        
        if (self.gameSceneDelegate &&
            [self.gameSceneDelegate
             respondsToSelector:@selector(showMCBrowserControllerForSession:serviceType:)])
        {
            [self.gameSceneDelegate showMCBrowserControllerForSession:self.gameSession
                                                          serviceType:self.serviceType];
        }
    }
    else if (self.gameState == kGameStatePlaying)
    {
        
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

#pragma mark - MCSessionDelegate Methods

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    // A peer has changed state - it's now either connecting, connected, or disconnected.
    
    if (state == MCSessionStateConnected)
    {
        NSLog(@"state == MCSessionStateConnected");
        
        // Remember the current peer.
        self.gamePeerID = peerID;
        // Make sure we have a reference to the game session and it is set up
        self.gameSession = session;
        self.gameSession.delegate = self;
        self.gameState = kGameStatePlayerAllotment;
        
        self.gameInfoLabel.text = kGameStartedText;
        
        [self sendNetworkPacketToPeerId:self.gamePeerID
                          forPacketCode:KNetworkPacketCodePlayerAllotment
                               withData:&gameUniqueIdForPlayerAllocation
                               ofLength:sizeof(int)
                               reliable:YES];
    }
    else if (state == MCSessionStateConnecting)
    {
        NSLog(@"state == MCSessionStateConnecting");
    }
    else if (state == MCSessionStateNotConnected)
    {
        NSLog(@"state == MCSessionStateNotConnected");
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    // Data has been received from a peer.
    
    // Do something with the received data, on the main thread
    [[NSOperationQueue mainQueue]  addOperationWithBlock:^{
        // Process the data
        
        unsigned char *incomingPacket = (unsigned char *)[data bytes];
        int *pIntData = (int *)&incomingPacket[0];
        NetworkPacketCode packetCode = (NetworkPacketCode)pIntData[1];
        
        switch( packetCode ) {
            case KNetworkPacketCodePlayerAllotment:
            {
                NSInteger gameUniqueId = pIntData[2];
                
                if (gameUniqueIdForPlayerAllocation > gameUniqueId)
                {
                    self.gameInfoLabel.text = kFirstPlayerLabelText;
                }
                else
                {
                    self.gameInfoLabel.text = kSecondPlayerLabelText;
                }
                break;
            }
            default:
            break;
        }

    }];
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    // A file started being sent from a peer. (Not used in this example.)
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    // A file finished being sent from a peer. (Not used in this example.)
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    // Data started being streamed from a peer. (Not used in this example.)
}

#pragma mark - Networking Related Methods

- (void)instantiateMCSession
{
    if (self.gameSession == nil)
    {
        UIDevice *device = [UIDevice currentDevice];
        MCPeerID* peerID = [[MCPeerID alloc] initWithDisplayName:device.name];
        
        self.gameSession = [[MCSession alloc] initWithPeer:peerID];
        self.gameSession.delegate = self;
        
        self.serviceType = @"TankFight"; // should be unique
        
        self.advertiser =
        [[MCAdvertiserAssistant alloc] initWithServiceType:self.serviceType
                                             discoveryInfo:nil
                                                   session:self.gameSession];
        [self.advertiser start];
    }
}

- (void)sendNetworkPacketToPeerId:(MCPeerID*)peerId
                    forPacketCode:(NetworkPacketCode)packetCode
                         withData:(void *)data
                         ofLength:(NSInteger)length
                         reliable:(BOOL)reliable
{
    // the packet we'll send is resued
    static unsigned char networkPacket[kMaxTankPacketSize];
    const unsigned int packetHeaderSize = 2 * sizeof(int); // we have two "ints" for our header
    
    if(length < (kMaxTankPacketSize - packetHeaderSize))
    {
        // our networkPacket buffer size minus the size of the header info
        int *pIntData = (int *)&networkPacket[0];
        
        // header info
        pIntData[0] = self.gamePacketNumber++;
        pIntData[1] = packetCode;
        
        if (data)
        {
            // copy data in after the header
            memcpy( &networkPacket[packetHeaderSize], data, length );
        }
        
        NSData *packet = [NSData dataWithBytes: networkPacket length: (length+8)];
        
        NSError* error;
        
        if(reliable == YES)
        {
            [self.gameSession sendData:packet
                               toPeers:[NSArray arrayWithObject:peerId]
                              withMode:MCSessionSendDataReliable
                                 error:&error];
        }
        else
        {
            [self.gameSession sendData:packet
                               toPeers:[NSArray arrayWithObject:peerId]
                              withMode:MCSessionSendDataUnreliable
                                 error:&error];
        }
        
        if (error)
        {
            NSLog(@"Error:%@",[error description]);
        }
    }
}

#pragma mark - Adding Assets Methods

- (void)addGameInfoLabelWithText:(NSString*)labelText
{
    if (self.gameInfoLabel == nil) {
        self.gameInfoLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.gameInfoLabel.text = labelText;
        self.gameInfoLabel.fontSize = 32;
        self.gameInfoLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                                  CGRectGetMidY(self.frame));
        self.gameInfoLabel.zPosition = 100;
        
        [self addChild:self.gameInfoLabel];
    }
}

@end
