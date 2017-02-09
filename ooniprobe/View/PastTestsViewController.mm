// Part of MeasurementKit <https://measurement-kit.github.io/>.
// MeasurementKit is free software. See AUTHORS and LICENSE for more
// information on the copying conditions.

#import "PastTestsViewController.h"

/*Include header from test*/
#include "measurement_kit/ooni.hpp"

#include "measurement_kit/common.hpp"

@interface PastTestsViewController ()
@property (readwrite) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation PastTestsViewController : UITableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector(revealLeftView)];
    self.revealViewController.leftPresentViewHierarchically = YES;
    self.revealViewController.toggleAnimationType = PBRevealToggleAnimationTypeSpring;
    [self.revealViewController setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"reloadTable" object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:FALSE] forKey:@"new_tests"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = NSLocalizedString(@"past_tests", nil);
    [self reloadTable];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.title = nil;
}

-(void)reloadTable{
    finishedTests = [[TestStorage get_tests_rev] mutableCopy];
    [self.tableView reloadData];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)revealControllerPanGestureShouldBegin:(PBRevealViewController *)revealController direction:(PBRevealControllerPanDirection)direction{
    if (direction == PBRevealControllerPanDirectionRight)
        return YES;
    else if (revealController.isLeftViewOpen)
        return YES;
    return NO;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [finishedTests count];
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NetworkMeasurement *current;
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_test" forIndexPath:indexPath];
    current = [finishedTests objectAtIndex:indexPath.row];
    UILabel *title = (UILabel*)[cell viewWithTag:1];
    UILabel *subtitle = (UILabel*)[cell viewWithTag:2];
    UIImageView *image = (UIImageView*)[cell viewWithTag:3];
    RunButton *viewTest = (RunButton*)[cell viewWithTag:4];
    if (!current.viewed){
        viewTest.badgeValue = @" ";
        viewTest.badgeBGColor = color_ok_green;
        viewTest.badgeOriginX   = viewTest.frame.size.width - viewTest.badge.frame.size.width/2 -2;
        viewTest.badgeOriginY   = -5;
        viewTest.badgePadding = 1;
     }
    else
        viewTest.badgeValue = 0;

    [title setText:NSLocalizedString(current.name, nil)];
    [viewTest setTitle:NSLocalizedString(@"view", nil) forState:UIControlStateNormal];
    
    NSDate *timestampDate = [NSDate dateWithTimeIntervalSince1970:[current.test_id doubleValue]];
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [subtitle setText:[formatter stringFromDate:timestampDate]];
    //NSArray *items = [Tests getItems:current.json_file];
    if (current.entry){
        if (current.anomaly == 0){
            [image setImage:[UIImage imageNamed:current.name]];
            title.textColor = color_ooni_blue;
        }
        else {
            [image setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_no", current.name]]];
            title.textColor = color_bad_red;
        }
    }
    else {
        [image setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_warning", current.name]]];
        title.textColor = color_warning_orange;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NetworkMeasurement *current = [finishedTests objectAtIndex:indexPath.row];
    [self goToTest:current];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(IBAction)viewTest:(id)sender event:(id)event{
    CGPoint currentTouchPosition = [[[event allTouches] anyObject] locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    NetworkMeasurement *current = [finishedTests objectAtIndex:indexPath.row];
    [self goToTest:current];
}

-(void)goToTest:(NetworkMeasurement*)current{
    nextTest = current;
    //NSArray *items = [Tests getItems:nextTest.json_file];
    if (!nextTest.viewed){
        [TestStorage set_viewed:nextTest.test_id];
        [self reloadTable];
    }
    if ([current.name isEqualToString:@"web_connectivity"])
        [self performSegueWithIdentifier:@"toInputList" sender:self];
    else if (current.entry)
        [self performSegueWithIdentifier:@"toResult" sender:self];
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_result", nil) message:NSLocalizedString(@"no_result_msg", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"") otherButtonTitles:nil];
        [alert show];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NetworkMeasurement *current = [finishedTests objectAtIndex:indexPath.row];
        [finishedTests removeObjectAtIndex:indexPath.row];
        [TestStorage remove_test:current.test_id];
        [self reloadTable];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toResult"]){
        //NSArray *items = [Tests getItems:nextTest.json_file];
        JSONFileReader *jReader = [[JSONFileReader alloc] initWithFile:nextTest.json_file encoding:NSUTF8StringEncoding];
        ResultViewController *vc = (ResultViewController * )segue.destinationViewController;
        //[vc setContent:[items objectAtIndex:0]];
        [vc setContent:[jReader readLine]];
        [vc setTestName:nextTest.name];
        [vc setLog_file:nextTest.log_file];
    }
    else if ([[segue identifier] isEqualToString:@"toInputList"]){
        ResultSelectorViewController *vc = (ResultSelectorViewController * )segue.destinationViewController;
       //[vc setItems:[Tests getItems:nextTest.json_file]];
        [vc setTestName:nextTest.name];
        [vc setLog_file:nextTest.log_file];
        [vc setJson_file:nextTest.json_file];
    }
}

@end
