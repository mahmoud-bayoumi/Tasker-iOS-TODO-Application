//
//  AddTaskViewController.m
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//
#import "AddTaskViewController.h"
#import "Task.h"
#import "TaskManager.h"
#import <UserNotifications/UserNotifications.h>

@interface AddTaskViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegment;

@property (weak, nonatomic) IBOutlet UIDatePicker *reminderDatePicker;

@property (weak, nonatomic) IBOutlet UILabel *reminderAtLabel;

@property (nonatomic, assign) TaskPriority selectedPriority;
@property (nonatomic, assign) BOOL reminderSet;
@property (nonatomic, strong) NSDate *originalPickerDate;

@end

@implementation AddTaskViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add New Task";
    
    self.selectedPriority = TaskPriorityLow;
    self.prioritySegment.selectedSegmentIndex = 0;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:@"Cancel"
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(cancelTapped)];

    self.reminderDatePicker.date = [NSDate date];
    self.reminderDatePicker.minimumDate = [NSDate date];
    self.reminderDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.reminderDatePicker.hidden = NO;  // Always visible
    
    self.originalPickerDate = self.reminderDatePicker.date;
    
    [self.reminderDatePicker addTarget:self
                                action:@selector(datePickerChanged:)
                      forControlEvents:UIControlEventValueChanged];
    
    self.reminderSet = NO;
    self.reminderAtLabel.hidden = YES;
    
    // ── Request Notification Permission ──
    [self requestNotificationPermission];
    
    NSLog(@"AddTaskViewController loaded");
}


- (IBAction)prioritySegmentAction:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0: self.selectedPriority = TaskPriorityLow; break;
        case 1: self.selectedPriority = TaskPriorityMedium; break;
        case 2: self.selectedPriority = TaskPriorityHigh; break;
        default: self.selectedPriority = TaskPriorityLow; break;
    }
}



- (void)datePickerChanged:(UIDatePicker *)picker {
    
    self.reminderSet = YES;
    
    [self updateReminderLabel];
    self.reminderAtLabel.hidden = NO;
    
    NSLog(@"User changed date → Reminder will be set");
}

- (void)updateReminderLabel {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"MMM dd, yyyy 'at' hh:mm a";
    fmt.timeZone = [NSTimeZone localTimeZone];
    
    self.reminderAtLabel.text = [NSString stringWithFormat:
        @"Reminder: %@", [fmt stringFromDate:self.reminderDatePicker.date]];
}


- (IBAction)removeReminderAction:(id)sender {

    self.reminderSet = NO;
    self.reminderAtLabel.hidden = YES;
    
    self.reminderDatePicker.date = [NSDate date];
    self.originalPickerDate = self.reminderDatePicker.date;
    
    NSLog(@"Reminder removed, picker reset to now");
}

// ── Keep setReminderAction if button exists (optional) ──
- (IBAction)setReminderAction:(id)sender {
    // If user taps "Set Reminder" button, treat as manual set
    self.reminderSet = YES;
    [self updateReminderLabel];
    self.reminderAtLabel.hidden = NO;
    
    NSLog(@"Reminder manually set");
}


- (void)requestNotificationPermission {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert |
                                             UNAuthorizationOptionSound |
                                             UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError *error) {
        if (granted) {
            NSLog(@"Notification permission granted");
        } else {
            NSLog(@"Notification permission denied");
        }
    }];
}

- (void)scheduleReminderNotification:(Task *)task {
    
    if (!task.reminderDate) return;
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Task Reminder";
    content.body = [NSString stringWithFormat:@"Don't forget: %@", task.name];
    content.sound = [UNNotificationSound defaultSound];
    
    NSDateComponents *components = [[NSCalendar currentCalendar]
        components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                    NSCalendarUnitHour | NSCalendarUnitMinute)
          fromDate:task.reminderDate];
    
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger
        triggerWithDateMatchingComponents:components repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest
        requestWithIdentifier:task.taskID
                      content:content
                      trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter]
        addNotificationRequest:request
         withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Notification error: %@", error.localizedDescription);
        } else {
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            fmt.dateFormat = @"MMM dd, yyyy 'at' hh:mm a";
            fmt.timeZone = [NSTimeZone localTimeZone];
            NSLog(@"Reminder scheduled for: %@ (local time)",
                  [fmt stringFromDate:task.reminderDate]);
        }
    }];
}



- (IBAction)addTask:(id)sender {
    
    NSString *name = [self.titleTextField.text
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (name.length == 0) {
        self.titleTextField.layer.borderWidth = 1.0;
        self.titleTextField.layer.borderColor = [UIColor systemRedColor].CGColor;
        self.titleTextField.layer.cornerRadius = 6;
        
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Missing Task Name"
            message:@"Please enter a name for your task."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                [self.titleTextField becomeFirstResponder];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.titleTextField.layer.borderWidth = 0;
    
    Task *task = [[Task alloc] init];
    task.name = name;
    task.taskDescription = self.descriptionTextField.text ?: @"";
    task.priority = self.selectedPriority;
    task.status = TaskStatusToDo;
    
    if (self.reminderSet) {
        task.reminderDate = self.reminderDatePicker.date;
        NSLog(@"Reminder will be set for this task");
    } else {
        task.reminderDate = nil;
        NSLog(@"No reminder — date picker was not changed");
    }
    
    [[TaskManager sharedManager] addTask:task];
    
    if (self.reminderSet) {
        [self scheduleReminderNotification:task];
    }
    
    NSLog(@"Task Created: %@ | Priority: %ld | Reminder: %@",
          task.name, (long)task.priority,
          self.reminderSet ? @"YES" : @"NO");
    
    NSMutableString *message = [NSMutableString stringWithFormat:
        @"\"%@\" has been added to your list.", name];
    
    if (self.reminderSet) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"MMM dd, yyyy 'at' hh:mm a";
        fmt.timeZone = [NSTimeZone localTimeZone];
        [message appendFormat:@"\n\nReminder set for:\n%@",
            [fmt stringFromDate:self.reminderDatePicker.date]];
    }
    
    UIAlertController *success = [UIAlertController
        alertControllerWithTitle:@"Task Created! ✓"
        message:message
        preferredStyle:UIAlertControllerStyleAlert];
    
    [success addAction:[UIAlertAction actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:success animated:YES completion:nil];
}


- (void)cancelTapped {
    
    BOOL hasTitle    = (self.titleTextField.text.length > 0);
    BOOL hasDesc     = (self.descriptionTextField.text.length > 0);
    BOOL hasReminder = self.reminderSet;
    
    if (hasTitle || hasDesc || hasReminder) {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Discard Task?"
            message:@"You have unsaved changes. Are you sure?"
            preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Keep Editing"
            style:UIAlertActionStyleCancel handler:nil]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Discard"
            style:UIAlertActionStyleDestructive
            handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
