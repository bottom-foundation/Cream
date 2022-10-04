//
//  ViewController.m
//  Cream
//
//  Created by Snoolie Keffaber on 9/29/22.
//

#import "ViewController.h"
#import "MangaViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_creamButton.layer setCornerRadius:5.0];
    // Do any additional setup after loading the view.
}
- (IBAction)willStartCreaming:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MangaViewController *myHornyVC = (MangaViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MangaViewController"];
    myHornyVC.nhentaiId = 123456789; //example, change to be valid
    [self.navigationController pushViewController:myHornyVC animated:YES];
}


@end
