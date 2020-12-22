//
//  GameScene.m
//  TankRace
//
//  Created by Rahul on 12/28/14.
//  Copyright (c) 2014 RahulBorawar. All rights reserved.
//

#import <GameKit/GameKit.h>

typedef enum {
    kGameStatePlayerToConnect,
    kGameStatePlayerAllotment,
    kGameStatePlaying,
    kGameStateComplete,
} GameState;

typedef enum {
    KNetworkPacketCodePlayerAllotment,
    KNetworkPacketCodePlayerMove,
    KNetworkPacketCodePlayerLost,
} NetworkPacketCode;

typedef struct {
    CGPoint		tankPreviousPosition;
    CGPoint		tankPosition;
    CGPoint		tankDestination;
    
    CGFloat		tankRotation;
    CGFloat		tankDirection;
} TankInfo;

// the cool "completely change the game" variables
const float kTankSpeed = 1.0f;
const float kTankTurnSpeed = 0.1f;

// Blue is the First and Red is the Second Player
#define kFirstPlayerLabelText  @"You're Blue"
#define kSecondPlayerLabelText @"You're Red"

// strings for game label
#define kConnectingDevicesText @"Tap to Connect"
#define kGameStartedText       @"Game Started"
#define kGameWonText           @"You Won"
#define kGameLostText          @"You Lost"
#define kConnectedDevicesText  @"Devices Connected"

#define kMaxTankPacketSize 1024

#import "GameScene.h"

@interface GameScene() <MCSessionDelegate>
{
    int gameUniqueIdForPlayerAllocation;
    TankInfo tankStatsForLocal;
}

@property (nonatomic, assign) int gamePacketNumber;

@property (nonatomic, strong) MCSession* gameSession;
@property (nonatomic, strong) MCPeerID* gamePeerID;
@property (nonatomic, strong) NSString* serviceType;
@property (nonatomic, strong) MCAdvertiserAssistant* advertiser;

@property (nonatomic, strong) SKLabelNode* gameInfoLabel;
@property (nonatomic, assign) GameState gameState;

@property (nonatomic, strong) SKSpriteNode* redTankSprite;
@property (nonatomic, strong) SKSpriteNode* blueTankSprite;

@property (nonatomic, strong) SKShapeNode* blueFinishLine;
@property (nonatomic, strong) SKShapeNode* redFinishLine;

@property (nonatomic, strong) SKSpriteNode* localTankSprite;
@property (nonatomic, strong) SKSpriteNode* remoteTankSprite;

@end

@implementation GameScene

#pragma mark - Overridden Methods

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    [self addGameBackground];
    
    [self addBLueFinishLine];
    [self addRedFinishLine];
    
    [self addBlueTank];
    [self addRedTank];
    
    gameUniqueIdForPlayerAllocation = arc4random();

    [self addGameInfoLabelWithText:kConnectingDevicesText];
     self.gameState = kGameStatePlayerToConnect;
}

#pragma mark - Public Methods

- (void)startGame
{
    if (self.gameState == kGameStatePlayerAllotment)
    {
        self.gameState = kGameStatePlaying;
        
        [self hideGameInfoLabelWithAnimation];
    }
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
        UITouch *thumb = [[event allTouches] anyObject];
        CGPoint thumbPoint = [thumb locationInNode:self];
        
        // hold to move, second finger to fire
        if(thumb.tapCount==0) {
            
            tankStatsForLocal.tankDestination = thumbPoint;
            tankStatsForLocal.tankDirection =
            atan2( thumbPoint.y - tankStatsForLocal.tankPosition.y,
                  thumbPoint.x - tankStatsForLocal.tankPosition.x ) -
            (M_PI/2.0);
            
            // keep us 0-359
            if(tankStatsForLocal.tankDirection < 0)
                tankStatsForLocal.tankDirection += (2.0*M_PI);
            else if(tankStatsForLocal.tankDirection > (2.0*M_PI))
                tankStatsForLocal.tankDirection -= (2.0*M_PI);
            
            [self updateLocalTank];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.gameState == kGameStatePlaying)
    {
        if([touches count] == 1)
        {
            UITouch *thumb = [[event allTouches] anyObject];
            CGPoint thumbPoint = [thumb locationInNode:self];
            
            tankStatsForLocal.tankDestination = thumbPoint;
            tankStatsForLocal.tankDirection =
            atan2( thumbPoint.y - tankStatsForLocal.tankPosition.y,
                  thumbPoint.x - tankStatsForLocal.tankPosition.x ) - (M_PI/2.0);
            
            // keep us 0-359
            if(tankStatsForLocal.tankDirection < 0)
                tankStatsForLocal.tankDirection += (2.0*M_PI);
            else if(tankStatsForLocal.tankDirection > (2.0*M_PI))
                tankStatsForLocal.tankDirection -= (2.0*M_PI);
            
            [self updateLocalTank];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.gameState == kGameStatePlaying)
    {
        if([touches count] == [[event touchesForView:self.view] count])
        {
            tankStatsForLocal.tankDestination = tankStatsForLocal.tankPosition;
            tankStatsForLocal.tankDirection = tankStatsForLocal.tankRotation;
            
            [self updateLocalTank];
        }
    }
}

#pragma mark - Update Loop Method

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    CGRect blueFinishLineFrame =
    CGRectMake(0, self.frame.size.height * 0.15, self.frame.size.width, 1);
    
    CGRect redFinishLineFrame =
    CGRectMake(0, self.frame.size.height * 0.85, self.frame.size.width, 1);
    
    if (self.localTankSprite == self.blueTankSprite &&
        CGRectIntersectsRect(self.localTankSprite.frame, blueFinishLineFrame))
    {
        self.gameState = kGameStateComplete;
        [self addGameInfoLabelWithText:kGameWonText];
        
        [self restartGameAfterSomeTime];
        
        [self sendNetworkPacketToPeerId:self.gamePeerID
                          forPacketCode:KNetworkPacketCodePlayerLost
                               withData:nil
                               ofLength:0
                               reliable:YES];
    }
    else if(self.localTankSprite == self.redTankSprite &&
            CGRectIntersectsRect(self.localTankSprite.frame, redFinishLineFrame))
    {
        self.gameState = kGameStateComplete;
        [self addGameInfoLabelWithText:kGameWonText];
        
        [self restartGameAfterSomeTime];
        
        [self sendNetworkPacketToPeerId:self.gamePeerID
                          forPacketCode:KNetworkPacketCodePlayerLost
                               withData:nil
                               ofLength:0
                               reliable:YES];
    }
}

- (void)updateLocalTank
{
    if( (fabs(tankStatsForLocal.tankPosition.x - tankStatsForLocal.tankDestination.x)>kTankSpeed) ||
       (fabs(tankStatsForLocal.tankPosition.y - tankStatsForLocal.tankDestination.y)>kTankSpeed) ) {
        // check facing
        float ad = tankStatsForLocal.tankDirection - tankStatsForLocal.tankRotation;
        
        if(fabs(ad) > kTankTurnSpeed) {
            // we need to turn, work out which way (find the closest 180)
            while(ad > M_PI) {
                ad -= (2.0 * M_PI);
            }
            while(ad < -M_PI) {
                ad += (2.0 * M_PI);
            }
            if(ad < 0) {
                tankStatsForLocal.tankRotation -= kTankTurnSpeed;
                if(tankStatsForLocal.tankRotation < 0)
                    tankStatsForLocal.tankRotation += (2.0*M_PI);
            } else if(ad > 0) {
                tankStatsForLocal.tankRotation += kTankTurnSpeed;
                if(tankStatsForLocal.tankRotation > (2.0*M_PI))
                    tankStatsForLocal.tankRotation -= (2.0*M_PI);
            }
        } else {
            tankStatsForLocal.tankRotation = tankStatsForLocal.tankDirection;
            // if facing move along line towards destination
            float dx = tankStatsForLocal.tankPosition.x - tankStatsForLocal.tankDestination.x;
            float dy = tankStatsForLocal.tankPosition.y - tankStatsForLocal.tankDestination.y;
            float at = atan2( dy, dx );
            // 1.0 is the "speed"
            tankStatsForLocal.tankPosition.x -= kTankSpeed * cos(at);
            tankStatsForLocal.tankPosition.y -= kTankSpeed * sin(at);
        }
    } else {
        tankStatsForLocal.tankPosition.x = tankStatsForLocal.tankDestination.x;
        tankStatsForLocal.tankPosition.y = tankStatsForLocal.tankDestination.y;
    }
    
    tankStatsForLocal.tankPreviousPosition = self.localTankSprite.position;
    
    self.localTankSprite.position = tankStatsForLocal.tankPosition;
    self.localTankSprite.zRotation = tankStatsForLocal.tankRotation;
    
    // Send NetworkPacket for syncing the data at both the players
    
    [self sendNetworkPacketToPeerId:self.gamePeerID
                      forPacketCode:KNetworkPacketCodePlayerMove
                           withData:&tankStatsForLocal
                           ofLength:sizeof(TankInfo)
                           reliable:YES];
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
        
        if (self.gameState == kGameStatePlaying)
        {
            [self showNetworkDisconnectAlertView];
        }
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
                    
                    self.localTankSprite = self.blueTankSprite;
                    self.remoteTankSprite = self.redTankSprite;
                }
                else
                {
                    self.gameInfoLabel.text = kSecondPlayerLabelText;
                    
                    self.localTankSprite = self.redTankSprite;
                    self.remoteTankSprite = self.blueTankSprite;
                }
                
                [self resetLocalTanksAndInfoToInitialState];
                
                break;
            }
            case KNetworkPacketCodePlayerMove:
            {
                // received move event from other player, update other player's position/destination info
                TankInfo *ts = (TankInfo *)&incomingPacket[8];
                
                self.remoteTankSprite.position = ts->tankPosition;
                self.remoteTankSprite.zRotation = ts->tankRotation;
                break;
            }
            case KNetworkPacketCodePlayerLost:
            {
                self.gameState = kGameStateComplete;
                [self addGameInfoLabelWithText:kGameLostText];
                
                [self restartGameAfterSomeTime];
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

#pragma mark - Game Updation Methods

- (void)resetLocalTanksAndInfoToInitialState
{
    if (self.localTankSprite == self.blueTankSprite &&
        self.remoteTankSprite == self.redTankSprite)
    {
        tankStatsForLocal.tankPosition =
        CGPointMake(self.frame.size.width/2,self.frame.size.height * 0.95);
        tankStatsForLocal.tankRotation = M_PI;
        
        self.localTankSprite.position = tankStatsForLocal.tankPosition;
        self.localTankSprite.zRotation = tankStatsForLocal.tankRotation;
        
        self.remoteTankSprite.position =
        CGPointMake(self.frame.size.width/2,self.frame.size.height * 0.05);
        self.remoteTankSprite.zRotation = 0.0;
    }
    else if (self.localTankSprite == self.redTankSprite &&
             self.remoteTankSprite == self.blueTankSprite)
    {
        tankStatsForLocal.tankPosition =
        CGPointMake(self.frame.size.width/2,self.frame.size.height * 0.05);
        tankStatsForLocal.tankRotation = 0.0;
        
        self.localTankSprite.position = tankStatsForLocal.tankPosition;
        self.localTankSprite.zRotation = tankStatsForLocal.tankRotation;
        
        self.remoteTankSprite.position =
        CGPointMake(self.frame.size.width/2,self.frame.size.height * 0.95);
        self.remoteTankSprite.zRotation = M_PI;
    }
}

- (void)hideGameInfoLabelWithAnimation
{
    SKAction* gameInfoLabelHoldAnimationCallBack =
    [SKAction customActionWithDuration:2.0
                           actionBlock:^(SKNode *node,CGFloat elapsedTime)
     {
     }];
    
    SKAction* gameInfoLabelFadeOutAnimation =
    [SKAction fadeOutWithDuration:1.0];
    
    SKAction* gameInfoLabelRemoveAnimationCallBack =
    [SKAction customActionWithDuration:0.0
                           actionBlock:^(SKNode *node,CGFloat elapsedTime)
     {
         [node removeFromParent];
         
         self.gameInfoLabel = nil;
     }];
    
    NSArray* gameLabelAnimationsSequence =
    [NSArray arrayWithObjects:gameInfoLabelHoldAnimationCallBack,gameInfoLabelFadeOutAnimation, gameInfoLabelRemoveAnimationCallBack, nil];
    SKAction* gameInfoSequenceAnimation =
    [SKAction sequence:gameLabelAnimationsSequence];
    [self.gameInfoLabel runAction:gameInfoSequenceAnimation];
}

- (void)restartGameAfterSomeTime
{
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(restartGame)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)restartGame
{
    gameUniqueIdForPlayerAllocation = arc4random();
    self.gameState = kGameStatePlayerToConnect;
    self.gameInfoLabel.text = kConnectingDevicesText;
    
    [self resetLocalTanksAndInfoToInitialState];
}

- (void)showNetworkDisconnectAlertView
{
    UIAlertView* alertView =
    [[UIAlertView alloc] initWithTitle:@"Network Disconnected"
                               message:@"Sorry due some network problem devices are disconnected. To start game again kill apps in both devices and restart the app!!"
                              delegate:self
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // do nothing
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

- (void)addGameBackground
{
    SKSpriteNode *gameBGNode =
    [SKSpriteNode spriteNodeWithImageNamed:@"Background.png"];
    {
        gameBGNode.position =
        CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
        gameBGNode.zPosition = 0;
        [self addChild:gameBGNode];
    }
}

- (void)addBLueFinishLine
{
    CGRect frame = CGRectMake(0, self.frame.size.height * 0.15, self.frame.size.width, 1);
    
    self.blueFinishLine = [SKShapeNode shapeNodeWithRect:frame];
    {
        self.blueFinishLine.strokeColor = [UIColor blueColor];
        self.blueFinishLine.zPosition = 2;
        [self addChild:self.blueFinishLine];
    }
}

- (void)addRedFinishLine
{
    CGRect frame = CGRectMake(0, self.frame.size.height * 0.85, self.frame.size.width, 1);
    
    self.redFinishLine = [SKShapeNode shapeNodeWithRect:frame];
    {
        self.redFinishLine.strokeColor = [UIColor redColor];
        self.redFinishLine.zPosition = 1;
        
        [self addChild:self.redFinishLine];
    }
}

- (void)addBlueTank
{
    self.blueTankSprite = [SKSpriteNode spriteNodeWithImageNamed:@"BlueTank.png"];
    
    self.blueTankSprite.position =
    CGPointMake(self.frame.size.width/2,self.frame.size.height * 0.95);
    self.blueTankSprite.zRotation = M_PI;
    self.blueTankSprite.zPosition = 2;
    
    [self addChild:self.blueTankSprite];
}

- (void)addRedTank
{
    self.redTankSprite = [SKSpriteNode spriteNodeWithImageNamed:@"RedTank.png"];
    
    self.redTankSprite.position =
    CGPointMake(self.frame.size.width/2,self.frame.size.height * 0.05);
    self.redTankSprite.zRotation = 0.0;
    self.redTankSprite.zPosition = 2;
    
    [self addChild:self.redTankSprite];
}

@end
