//
//  BoardVC.m
//  CifrasSinLetras
//
//  Created by Delgado Molina Ismael on 22/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

// imports
#import "BoardVC.h"
#import <GameKit/GameKit.h>

@implementation BoardVC
@synthesize answerLabel;
@synthesize vowelButton;
@synthesize consonantButton;
@synthesize doneButton;
@synthesize clearButton;
@synthesize restTimeProgressView;
@synthesize restTimeLabel;

@synthesize letters;
@synthesize letter1,letter2,letter3,letter4,letter5,letter6,letter7,letter8,letter9;
@synthesize  answer;
@synthesize achievementsDictionary;

// constants
NSString *vowels = @"AEIOU";
NSString *consonants = @"BCDFGHJKLMNÑPQRSTVWXYZ";

// private properties
int currentPosition = 0;
NSTimer *theTimer;
float restSeconds = 60.0;
BOOL isGCSupported = NO;

#pragma mark - Gamecenter

-(BOOL)isGameCenterSupported
{
    Class gcClass = NSClassFromString(@"GKLocalPlayer");
    
    BOOL osVersionSupported = ([[[UIDevice currentDevice] systemVersion] 
                                compare:@"4.1" options:NSNumericSearch] != NSOrderedAscending);
    return (gcClass && osVersionSupported);
}

-(void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if ([localPlayer isAuthenticated] == YES)
    {
        NSLog(@"The local player has already authenticated.");
        return;
    }
    
    [localPlayer authenticateWithCompletionHandler:^(NSError *error){
        if (error == nil)
        {
            NSLog(@"Successfully authenticated the local player.");
        }
        else {
            NSLog(@"Failed to authenticate the player with error = %@", error);
        }
    }];
}

- (BOOL) reportScore:(NSUInteger)scorevalue toLeaderboard:(NSString *)leaderboard
{
    __block BOOL result = NO;
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    if ([localPlayer isAuthenticated] == NO)
    {
        NSLog(@"You must authenticate the local player first.");
        return NO; 
    }
    
    if ([leaderboard length] == 0)
    { 
        NSLog(@"Leaderboard identifier is empty."); 
        return NO;
    }
    
    GKScore *score = [[GKScore alloc] initWithCategory:leaderboard];
    score.value = (int64_t)scorevalue; 
    NSLog(@"Attempting to report the score...");
    [score reportScoreWithCompletionHandler:^(NSError *error) {
        if (error == nil)
        {   
            NSLog(@"Succeeded in reporting the score."); result = YES;
        } 
        else 
        {
            NSLog(@"Failed to report the score. Error = %@", error);
        } 
    }];
    return result;
}




- (void) loadAchievements
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error)
     {
         if (error == nil)
         {
             for (GKAchievement* achievement in achievements)
                 [achievementsDictionary setObject: achievement forKey:
                  achievement.identifier];
         }
     }]; 
}

- (GKAchievement*) getAchievementForIdentifier: (NSString*) identifier
{
    GKAchievement *achievement = [achievementsDictionary objectForKey:identifier]; 
    if (achievement == nil)
    {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        [achievementsDictionary setObject:achievement
                                   forKey:achievement.identifier];
    }
    return achievement;
}

-(void) reportAchievementWithID:(NSString *)achivementID percentageCompleted:(double)percentageCompleted
{        
    GKAchievement *achievement = [self getAchievementForIdentifier:achivementID];
    if (achievement)
    {
        achievement.percentComplete = achievement.percentComplete + percentageCompleted;
        NSLog(@"Reporting the achievement...");
        [achievement reportAchievementWithCompletionHandler:^(NSError *error){
            if (error == nil)
            {
                NSLog(@"Successfully reported the achievement.");
            } 
            else 
            {
                NSLog(@"Failed to report the achievement. %@", error);
            } 
        }];
    }
}

#pragma mark - Play methods

-(void)enableButtonsForPlay:(BOOL)enable
{
    if (enable) //playing
    {
        for (int i=0; i<self.letters.count; i++) {
            [(UIButton *)[self.letters objectAtIndex:i] setHidden:NO];
            [(UIButton *)[self.letters objectAtIndex:i] setEnabled:YES];
        }
        doneButton.enabled = YES;
        clearButton.enabled = YES;
        vowelButton.enabled = NO;
        consonantButton.enabled = NO;
        answerLabel.text = @"";
                
        if (![theTimer isValid])
        {
            restSeconds = 60.0;
            theTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRestTime:) userInfo:nil repeats:YES];
        }
    }
    else { //selecting
        for (int i=0; i<self.letters.count; i++) {
            [(UIButton *)[self.letters objectAtIndex:i] setEnabled:NO];
            [(UIButton *)[self.letters objectAtIndex:i] setHidden:NO];
            [(UIButton *)[self.letters objectAtIndex:i] setTitle:@"" forState:UIControlStateNormal];
            
        }
        doneButton.enabled = NO;
        clearButton.enabled = NO;
        vowelButton.enabled = YES;
        consonantButton.enabled = YES;
        answerLabel.text = @"";
        currentPosition = 0;
        restTimeLabel.text = @"";
        [restTimeProgressView setProgress:0.0];
        if (theTimer.isValid)
        {
            [theTimer invalidate];
        }
    }
}

-(void)setButtonLetter:(NSString *)theLetter
{
    UIButton *aButton = [letters objectAtIndex:currentPosition];
    [aButton setTitle:theLetter forState:UIControlStateNormal];
    currentPosition++;
    if (currentPosition >= 9)
    {
        [self enableButtonsForPlay:YES];
    }
}

- (IBAction)addVowel:(id)sender {
    NSUInteger randomVowel = arc4random() % 5;
    NSString *vowel = [vowels substringWithRange:NSMakeRange(randomVowel, 1)];
    [self setButtonLetter:vowel];
}

- (IBAction)addConsonant:(id)sender {
    NSUInteger randomConsonant = arc4random() % 22;
    NSString *consonant = [consonants substringWithRange:NSMakeRange(randomConsonant, 1)];
    [self setButtonLetter:consonant];
    
}

- (IBAction)endMatch:(id)sender {
    self.answer = answerLabel.text;
    [self enableButtonsForPlay:NO];
    UIAlertView *endAlert;
    NSString *message;
    
    if (nil == self.answer || [self.answer isEqualToString:@""])
    {
        message = @"Please try again";
    }
    else {
        message = [NSString stringWithFormat:@"Remained %.0f seconds", restSeconds];
    }

    endAlert = [[UIAlertView alloc] initWithTitle:self.answer message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [endAlert show];
    if (self.answer.length > 0)
    {
        [self reportScore:self.answer.length toLeaderboard:@"LSC.PalabraMasLarga"];
        if (self.answer.length >= 6)
        {
            [self reportAchievementWithID:@"LSC.SeisLetras" percentageCompleted:20.0];
        }
    }

    
}

- (IBAction)useLetter:(id)sender {
    NSString *selectedLetter = [[(UIButton *)sender titleLabel] text];
    answerLabel.text = [answerLabel.text stringByAppendingString:selectedLetter];
    [(UIButton *)sender setHidden:YES];
    
}

- (IBAction)clearAnswer:(id)sender {
    [self enableButtonsForPlay:YES];
}


-(void)updateRestTime:(NSTimer *)aTimer
{
    NSLog(@"El timer ha saltado. Quedan %f segundos", restSeconds);
    restSeconds--;
    [restTimeLabel setText:[NSString stringWithFormat:@"%.0f", restSeconds]];
    [restTimeProgressView setProgress:(60 - restSeconds)/60];
    if (restSeconds <= 0.0)
    {
        [aTimer invalidate];
        [self enableButtonsForPlay:NO];
        UIAlertView *endAlert = [[UIAlertView alloc] initWithTitle:@"Time finished!" message:@"Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [endAlert show];
    }
    
}

#pragma mark - View lifecycle


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.letters = [NSArray arrayWithObjects:letter1, 
                    letter2,letter3,letter4,letter5,
                    letter6,letter7,letter8,letter9,nil];
    [self enableButtonsForPlay:NO];
    isGCSupported = [self isGameCenterSupported];
        if (isGCSupported)
    {
        [self authenticateLocalPlayer];
    }
    achievementsDictionary = [[NSMutableDictionary alloc] init];

}

- (void)viewDidUnload
{
    [self setAnswerLabel:nil];
    [self setLetter1:nil];
    [self setLetter2:nil];
    [self setLetter3:nil];
    [self setLetter4:nil];
    [self setLetter5:nil];
    [self setLetter6:nil];
    [self setLetter7:nil];
    [self setLetter8:nil];
    [self setLetter9:nil];
    [self setVowelButton:nil];
    [self setConsonantButton:nil];
    [self setDoneButton:nil];
    [self setClearButton:nil];
    [self setRestTimeProgressView:nil];
    [self setRestTimeLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
