#import "FirstViewController.h"
#import "Setting.h"

@implementation FirstViewController

@synthesize nameLabel, ageLabel;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"appear");
    [super viewWillAppear:animated];

    Setting *setting = [Setting findByKey:@"mySetting"];
    if (!setting) {
        setting = [Setting modelWithKey:@"mySetting"];
        setting.name = @"none";
        setting.age = 34;
        [setting save];
    }

    nameLabel.text = [NSString stringWithFormat:@"Name: %@", setting.name];
    ageLabel.text = [NSString stringWithFormat:@"Age: %d", setting.age];
}

@end
