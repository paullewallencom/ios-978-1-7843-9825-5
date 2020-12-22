//
//  GameViewController.m
//  TankRace
//
//  Created by Rahul on 12/28/14.
//  Copyright (c) 2014 RahulBorawar. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@interface GameViewController() <MCBrowserViewControllerDelegate, GameSceneDelegate>

@property (nonatomic, strong) GameScene* gameScene;

@end

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    self.gameScene = [GameScene unarchiveFromFile:@"GameScene"];
    self.gameScene.scaleMode = SKSceneScaleModeAspectFill;
    
    self.gameScene.gameSceneDelegate = self;
    
    // Present the scene.
    [skView presentScene:self.gameScene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - MCBrowserViewControllerDelegate Methods

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    // The MCSession is now ready to use.
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.gameScene)
    {
        [self.gameScene startGame];
    }
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    // The user cancelled.
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.gameScene)
    {
        [self.gameScene discardSession];
    }
}


#pragma mark - GameSceneDelegate Methods

- (void)showMCBrowserControllerForSession:(MCSession*)session
                              serviceType:(NSString*)serviceType
{
    MCBrowserViewController* viewController = [[MCBrowserViewController alloc] initWithServiceType:serviceType session:session];
    
    viewController.minimumNumberOfPeers = 2;
    viewController.maximumNumberOfPeers = 2;
    
    viewController.delegate = self;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
