//
//  ViewController.m
//  asteroid-defense
//
//  Created by Adam Borzecki on 2014-04-12.
//  Copyright (c) 2014 Adam Borzecki. All rights reserved.
//

#import "ViewController.h"
#import "GameManager.h"

@implementation ViewController
{
    Space *space;
    CGSize sceneBoundsSize;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
    sceneBoundsSize = skView.bounds.size;
    space = [self spawnSpace];
    
    // Present the scene.
    [skView presentScene:space];
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

- (void)spaceDidRequestToTryAgain:(Space *)theSpace
{
    SKView * skView = (SKView *)self.view;
    [skView presentScene:nil];
    
    [GameManager.sharedManager resetGameManager];
    
    space = nil;
    space = [self spawnSpace];
    [skView presentScene:space];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (Space *)spawnSpace
{
    Space * scene = [Space sceneWithSize:sceneBoundsSize];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.delegate = self;
    return scene;
}

@end
