//
//  BoardVC.m
//  CifrasSinLetras
//
//  Created by Delgado Molina Ismael on 22/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BoardVC.h"

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

NSString *vowels = @"AEIOU";
NSString *consonants = @"BCDFGHJKLMNÑPQRSTVWXYZ";

int currentPosition = 0;
NSTimer *theTimer;
float restSeconds = 60.0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

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
        
        //answer = @"";
        
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
        //answer = @"";
        currentPosition = 0;
        restTimeLabel.text = @"";
        [restTimeProgressView setProgress:0.0];
        if (theTimer.isValid)
        {
            [theTimer invalidate];
        }
    }
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.letters = [NSArray arrayWithObjects:letter1, 
                    letter2,letter3,letter4,letter5,
                    letter6,letter7,letter8,letter9,nil];
    [self enableButtonsForPlay:NO];
//    theTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateRestTime:) userInfo:nil repeats:YES];
    


    // Do any additional setup after loading the view from its nib.
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)setButtonLetter:(NSString *)theLetter
{
    UIButton *aButton = [letters objectAtIndex:currentPosition];
    //aButton.titleLabel.text = vowel;
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
    NSString *message = [NSString stringWithFormat:@"Remained %.0f seconds", restSeconds];
    UIAlertView *endAlert = [[UIAlertView alloc] initWithTitle:self.answer message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [endAlert show];
    
}

- (IBAction)useLetter:(id)sender {
    NSString *selectedLetter = [[(UIButton *)sender titleLabel] text];
    answerLabel.text = [answerLabel.text stringByAppendingString:selectedLetter];
    [(UIButton *)sender setHidden:YES];
    
}

- (IBAction)clearAnswer:(id)sender {
    [self enableButtonsForPlay:YES];
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    [self enableButtonsForPlay:NO];
//}

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
@end
