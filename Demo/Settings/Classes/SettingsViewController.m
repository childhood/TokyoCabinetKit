#import "SettingsViewController.h"
#import "Setting.h"

static UITextField *nameField = nil;
static Setting *setting = nil;

@implementation SettingsViewController

@synthesize picker;

#pragma mark NSObject

- (void)dealloc {
    if (nameField)
        [nameField release];

    [super dealloc];
}

#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //[(UITableView *)[self.view viewWithTag:1] setAllowsSelection:NO];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        if ([indexPath row] == 0) {
            if (!nameField) {
                nameField = [[[UITextField alloc] init] autorelease];
                nameField.placeholder = @"ユーザーID";
                nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                nameField.autocorrectionType = UITextAutocorrectionTypeNo;
                nameField.keyboardType = UIKeyboardTypeASCIICapable;
                nameField.delegate = self;
                nameField.tag = 1;
                nameField.frame = CGRectMake(20, 12, cell.frame.size.width - 40, cell.frame.size.height - 24);
            }
            [cell addSubview:nameField];
        } else {
        }
    }

    if (!setting) {
        setting = [[Setting findByKey:@"mySetting"] retain];
        NSLog(@"setting: %@", setting);
    }

    if ([indexPath row] == 0) {
        nameField.text = setting.name;
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"Age: %d", setting.age];
    }

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
    if ([indexPath row] == 0) {
        [nameField becomeFirstResponder];
        picker.hidden = YES;
    } else {
        [nameField resignFirstResponder];
        picker.hidden = NO;
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSUInteger indexes[] = { 0, 0 };
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
    [(UITableView *)[self.view viewWithTag:1] selectRowAtIndexPath:indexPath
                                  animated:NO
                            scrollPosition:UITableViewScrollPositionTop];

    picker.hidden = YES;

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    setting.name = textField.text;
    NSLog(@"name: %@", setting.name);
    [setting save];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // dismiss the keyboard
    [textField resignFirstResponder];

    return YES;
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 130;
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%d", row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    setting.age = row;
    NSLog(@"age: %d", setting.age);
    [setting save];
    [(UITableView *)[self.view viewWithTag:1] reloadData];
}

@end

