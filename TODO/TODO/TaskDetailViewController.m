//
//  TaskDetailViewController.m
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//


#import "TaskDetailViewController.h"
#import "TaskManager.h"
#import <QuickLook/QuickLook.h>


@interface TaskDetailViewController () <QLPreviewControllerDataSource, UIDocumentPickerDelegate>
@property (nonatomic, strong) Task *task;


@property (weak, nonatomic) IBOutlet UIImageView *taskImageView;
@property (weak, nonatomic) IBOutlet UILabel *priorityLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegmentControl;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statusSegment;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;

@property (weak, nonatomic) IBOutlet UILabel *reminderDisplayLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileDisplayLabel;

@property (nonatomic, assign) BOOL isEditMode;
@property (nonatomic, strong) NSString *originalName;
@property (nonatomic, strong) NSString *originalDescription;
@property (nonatomic, assign) TaskPriority originalPriority;
@property (nonatomic, strong) NSString *originalAttachedFileName;
@property (nonatomic, strong) NSString *originalAttachedFilePath;

@end

@implementation TaskDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Task Details";
    self.isEditMode = NO;
    
    self.taskImageView.layer.cornerRadius = 15;
    self.taskImageView.contentMode = UIViewContentModeCenter;
    
    [self.statusSegment removeAllSegments];
    [self.statusSegment insertSegmentWithTitle:@"To-Do" atIndex:0 animated:NO];
    [self.statusSegment insertSegmentWithTitle:@"In Progress" atIndex:1 animated:NO];
    [self.statusSegment insertSegmentWithTitle:@"Done" atIndex:2 animated:NO];
    
    [self.prioritySegmentControl removeAllSegments];
    [self.prioritySegmentControl insertSegmentWithTitle:@"Low" atIndex:0 animated:NO];
    [self.prioritySegmentControl insertSegmentWithTitle:@"Medium" atIndex:1 animated:NO];
    [self.prioritySegmentControl insertSegmentWithTitle:@"High" atIndex:2 animated:NO];
    
    [self updateNavBarButton];
    
    [self enterViewMode];
    
    [self populateData];
    
    [self.statusSegment addTarget:self
                           action:@selector(statusSegmentChanged:)
                 forControlEvents:UIControlEventValueChanged];
    
    [self.prioritySegmentControl addTarget:self
                                    action:@selector(prioritySegmentChanged:)
                          forControlEvents:UIControlEventValueChanged];
    
    if (self.fileDisplayLabel) {
        self.fileDisplayLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(fileDisplayTapped)];
        [self.fileDisplayLabel addGestureRecognizer:tap];
    }
    
    NSLog(@"TaskDetailViewController loaded");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self populateData];
}


- (void)updateNavBarButton {
    if (self.isEditMode) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:@"Done"
                    style:UIBarButtonItemStyleDone
                   target:self
                   action:@selector(doneEditingTapped)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:@"Cancel"
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(cancelEditTapped)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:@"Edit"
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(editTapped)];
        
        self.navigationItem.leftBarButtonItem = nil;
    }
}


- (void)enterViewMode {
    self.isEditMode = NO;
    
    self.nameLabel.hidden = NO;
    self.nameTextField.hidden = YES;
    
    self.descriptionLabel.hidden = NO;
    self.descriptionTextField.hidden = YES;
    
    self.priorityLabel.hidden = NO;
    self.prioritySegmentControl.hidden = YES;
    
    self.statusSegment.userInteractionEnabled = NO;
    
    [self updateNavBarButton];
}

- (void)enterEditMode {
    self.isEditMode = YES;
    
    self.originalName = self.task.name;
    self.originalDescription = self.task.taskDescription;
    self.originalPriority = self.task.priority;
    self.originalAttachedFileName = self.task.attachedFileName;
    self.originalAttachedFilePath = self.task.attachedFilePath;
    
    self.nameLabel.hidden = YES;
    self.nameTextField.hidden = NO;
    self.nameTextField.text = self.task.name;
    
    self.descriptionLabel.hidden = YES;
    self.descriptionTextField.hidden = NO;
    self.descriptionTextField.text = self.task.taskDescription;
    
    self.priorityLabel.hidden = YES;
    self.prioritySegmentControl.hidden = NO;
    switch (self.task.priority) {
        case TaskPriorityLow:    self.prioritySegmentControl.selectedSegmentIndex = 0; break;
        case TaskPriorityMedium: self.prioritySegmentControl.selectedSegmentIndex = 1; break;
        case TaskPriorityHigh:   self.prioritySegmentControl.selectedSegmentIndex = 2; break;
    }
    
    self.statusSegment.userInteractionEnabled = YES;
    [self applyStatusRestrictions];
    
    [self updateFileDisplayForEditMode];
    
    [self updateNavBarButton];
}


- (void)populateData {
    
    if (!self.task) return;
    
    [self updatePriorityDisplay:self.task.priority];
    
    self.nameLabel.text = self.task.name;
    
    if (self.task.taskDescription.length > 0) {
        self.descriptionLabel.text = self.task.taskDescription;
        self.descriptionLabel.textColor = [UIColor labelColor];
    } else {
        self.descriptionLabel.text = @"No description provided.";
        self.descriptionLabel.textColor = [UIColor secondaryLabelColor];
    }
    
    switch (self.task.status) {
        case TaskStatusToDo:       self.statusSegment.selectedSegmentIndex = 0; break;
        case TaskStatusInProgress: self.statusSegment.selectedSegmentIndex = 1; break;
        case TaskStatusDone:       self.statusSegment.selectedSegmentIndex = 2; break;
    }
    [self applyStatusRestrictions];
    
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"MMM dd, yyyy";
    NSDateFormatter *timeFmt = [[NSDateFormatter alloc] init];
    timeFmt.dateFormat = @"hh:mm a";
    
    self.createdAtLabel.text = [NSString stringWithFormat:@"Created: %@ at %@",
        [dateFmt stringFromDate:self.task.createdDate],
        [timeFmt stringFromDate:self.task.createdDate]];
    
    if (self.reminderDisplayLabel) {
        if (self.task.reminderDate) {
            self.reminderDisplayLabel.hidden = NO;
            self.reminderDisplayLabel.text = [NSString stringWithFormat:
                @"Reminder: %@ at %@",
                [dateFmt stringFromDate:self.task.reminderDate],
                [timeFmt stringFromDate:self.task.reminderDate]];
            self.reminderDisplayLabel.textColor = [UIColor systemBlueColor];
        } else {
            self.reminderDisplayLabel.hidden = YES;
        }
    }
    
    if (self.fileDisplayLabel) {
        if (self.task.attachedFileName) {
            self.fileDisplayLabel.hidden = NO;
            self.fileDisplayLabel.text = [NSString stringWithFormat:
                @"📎 File: %@ (Tap to view)", self.task.attachedFileName];
            self.fileDisplayLabel.textColor = [UIColor systemBlueColor];
        } else {
            self.fileDisplayLabel.hidden = YES;
        }
    }
}

- (void)fileDisplayTapped {
    
    if (self.isEditMode) {
        [self showFileEditOptions];
        return;
    }
    
    if (!self.task.attachedFilePath) return;
    
    BOOL exists = [[NSFileManager defaultManager]
        fileExistsAtPath:self.task.attachedFilePath];
    
    if (exists) {
        QLPreviewController *preview = [[QLPreviewController alloc] init];
        preview.dataSource = self;
        [self presentViewController:preview animated:YES completion:nil];
        
        NSLog(@"Opening file: %@", self.task.attachedFileName);
    } else {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"File Not Found"
            message:@"The attached file could not be found."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (void)updateFileDisplayForEditMode {
    if (self.fileDisplayLabel) {
        if (self.task.attachedFileName) {
            self.fileDisplayLabel.hidden = NO;
            self.fileDisplayLabel.text = [NSString stringWithFormat:
                @"📎 %@ (Tap to change/remove)", self.task.attachedFileName];
            self.fileDisplayLabel.textColor = [UIColor systemOrangeColor];
        } else {
            self.fileDisplayLabel.hidden = NO;
            self.fileDisplayLabel.text = @"📎 Tap to attach a file";
            self.fileDisplayLabel.textColor = [UIColor systemOrangeColor];
        }
    }
}

- (void)showFileEditOptions {
    UIAlertController *sheet = [UIAlertController
        alertControllerWithTitle:@"File Options"
        message:nil
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    [sheet addAction:[UIAlertAction
        actionWithTitle:@"Choose New File"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self presentDocumentPicker];
    }]];
    
    if (self.task.attachedFileName) {
        [sheet addAction:[UIAlertAction
            actionWithTitle:@"Remove File"
            style:UIAlertActionStyleDestructive
            handler:^(UIAlertAction *action) {
                [self removeAttachedFile];
        }]];
    }
    
    [sheet addAction:[UIAlertAction
        actionWithTitle:@"Cancel"
        style:UIAlertActionStyleCancel
        handler:nil]];
    
    sheet.popoverPresentationController.sourceView = self.fileDisplayLabel;
    sheet.popoverPresentationController.sourceRect = self.fileDisplayLabel.bounds;
    
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)presentDocumentPicker {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initWithDocumentTypes:@[@"public.item"]
        inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)removeAttachedFile {
    if (self.task.attachedFilePath &&
        ![self.task.attachedFilePath isEqualToString:self.originalAttachedFilePath ?: @""]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.task.attachedFilePath error:nil];
    }
    
    self.task.attachedFileName = nil;
    self.task.attachedFilePath = nil;
    
    [self updateFileDisplayForEditMode];
    
    NSLog(@"File removed from task");
}


- (void)documentPicker:(UIDocumentPickerViewController *)controller
    didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    
    if (urls.count == 0) return;
    
    NSURL *sourceURL = urls.firstObject;
    
    BOOL accessing = [sourceURL startAccessingSecurityScopedResource];
    
    NSString *documentsDir = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileName = sourceURL.lastPathComponent;
    NSString *destPath = [documentsDir stringByAppendingPathComponent:fileName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (self.task.attachedFilePath &&
        ![self.task.attachedFilePath isEqualToString:self.originalAttachedFilePath ?: @""]) {
        [fm removeItemAtPath:self.task.attachedFilePath error:nil];
    }
    
    if ([fm fileExistsAtPath:destPath]) {
        NSString *baseName = [fileName stringByDeletingPathExtension];
        NSString *extension = [fileName pathExtension];
        NSString *timestamp = [NSString stringWithFormat:@"%.0f",
            [[NSDate date] timeIntervalSince1970]];
        fileName = [NSString stringWithFormat:@"%@_%@.%@",
            baseName, timestamp, extension];
        destPath = [documentsDir stringByAppendingPathComponent:fileName];
    }
    
    NSError *error = nil;
    BOOL copied = [fm copyItemAtURL:sourceURL
                              toURL:[NSURL fileURLWithPath:destPath]
                              error:&error];
    
    if (accessing) {
        [sourceURL stopAccessingSecurityScopedResource];
    }
    
    if (copied) {
        self.task.attachedFileName = fileName;
        self.task.attachedFilePath = destPath;
        
        [self updateFileDisplayForEditMode];
        
        NSLog(@"New file attached: %@", fileName);
    } else {
        NSLog(@"Failed to copy file: %@", error.localizedDescription);
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Error"
            message:@"Failed to attach the file. Please try again."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"Document picker cancelled");
}



- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller
                    previewItemAtIndex:(NSInteger)index {
    return [NSURL fileURLWithPath:self.task.attachedFilePath];
}



- (void)updatePriorityDisplay:(TaskPriority)priority {
    switch (priority) {
        case TaskPriorityHigh:
            self.taskImageView.image = [UIImage systemImageNamed:@"flame.fill"];
            self.taskImageView.tintColor = [UIColor systemRedColor];
            self.taskImageView.backgroundColor =
                [[UIColor systemRedColor] colorWithAlphaComponent:0.15];
            self.priorityLabel.text = @"HIGH PRIORITY";
            self.priorityLabel.textColor = [UIColor systemRedColor];
            break;
        case TaskPriorityMedium:
            self.taskImageView.image = [UIImage systemImageNamed:@"bolt.fill"];
            self.taskImageView.tintColor = [UIColor systemOrangeColor];
            self.taskImageView.backgroundColor =
                [[UIColor systemOrangeColor] colorWithAlphaComponent:0.15];
            self.priorityLabel.text = @"MEDIUM PRIORITY";
            self.priorityLabel.textColor = [UIColor systemOrangeColor];
            break;
        case TaskPriorityLow:
            self.taskImageView.image = [UIImage systemImageNamed:@"leaf.fill"];
            self.taskImageView.tintColor = [UIColor systemGreenColor];
            self.taskImageView.backgroundColor =
                [[UIColor systemGreenColor] colorWithAlphaComponent:0.15];
            self.priorityLabel.text = @"LOW PRIORITY";
            self.priorityLabel.textColor = [UIColor systemGreenColor];
            break;
    }
}


- (void)applyStatusRestrictions {
    [self.statusSegment setEnabled:YES forSegmentAtIndex:0];
    [self.statusSegment setEnabled:YES forSegmentAtIndex:1];
    [self.statusSegment setEnabled:YES forSegmentAtIndex:2];
    
    switch (self.task.status) {
        case TaskStatusToDo:
            break;
        case TaskStatusInProgress:
            [self.statusSegment setEnabled:NO forSegmentAtIndex:0];
            [self.statusSegment setEnabled:NO forSegmentAtIndex:1];
            [self.statusSegment setEnabled:YES forSegmentAtIndex:2];
            break;
        case TaskStatusDone:
            [self.statusSegment setEnabled:NO forSegmentAtIndex:0];
            [self.statusSegment setEnabled:NO forSegmentAtIndex:1];
            [self.statusSegment setEnabled:NO forSegmentAtIndex:2];
            self.statusSegment.userInteractionEnabled = NO;
            break;
    }
}


- (void)statusSegmentChanged:(UISegmentedControl *)sender {
    TaskStatus newStatus;
    NSString *statusName;
    
    switch (sender.selectedSegmentIndex) {
        case 0: newStatus = TaskStatusToDo; statusName = @"To-Do"; break;
        case 1: newStatus = TaskStatusInProgress; statusName = @"In Progress"; break;
        case 2: newStatus = TaskStatusDone; statusName = @"Done"; break;
        default: return;
    }
    
    if (self.task.status == TaskStatusInProgress && newStatus == TaskStatusToDo) {
        sender.selectedSegmentIndex = 1;
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Not Allowed"
            message:@"In-progress tasks cannot go back to To-Do."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (self.task.status == TaskStatusDone) {
        sender.selectedSegmentIndex = 2;
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Not Allowed"
            message:@"Completed tasks cannot change status."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    UIAlertController *confirm = [UIAlertController
        alertControllerWithTitle:@"Change Status?"
        message:[NSString stringWithFormat:@"Mark this task as \"%@\"?", statusName]
        preferredStyle:UIAlertControllerStyleAlert];
    
    [confirm addAction:[UIAlertAction actionWithTitle:@"Cancel"
        style:UIAlertActionStyleCancel
        handler:^(UIAlertAction *action) {
            switch (self.task.status) {
                case TaskStatusToDo:       sender.selectedSegmentIndex = 0; break;
                case TaskStatusInProgress: sender.selectedSegmentIndex = 1; break;
                case TaskStatusDone:       sender.selectedSegmentIndex = 2; break;
            }
    }]];
    
    [confirm addAction:[UIAlertAction actionWithTitle:@"Confirm"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            self.task.status = newStatus;
            [[TaskManager sharedManager] saveTasks];
            [self applyStatusRestrictions];
    }]];
    
    [self presentViewController:confirm animated:YES completion:nil];
}

- (void)prioritySegmentChanged:(UISegmentedControl *)sender {
    TaskPriority newPriority;
    switch (sender.selectedSegmentIndex) {
        case 0: newPriority = TaskPriorityLow; break;
        case 1: newPriority = TaskPriorityMedium; break;
        case 2: newPriority = TaskPriorityHigh; break;
        default: newPriority = TaskPriorityLow; break;
    }
    [self updatePriorityDisplay:newPriority];
}



- (void)editTapped {
    [self enterEditMode];
}

- (void)doneEditingTapped {
    NSString *newName = [self.nameTextField.text
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (newName.length == 0) {
        self.nameTextField.layer.borderWidth = 1;
        self.nameTextField.layer.borderColor = [UIColor systemRedColor].CGColor;
        self.nameTextField.layer.cornerRadius = 6;
        
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Missing Task Name"
            message:@"Task name cannot be empty."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                [self.nameTextField becomeFirstResponder];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.nameTextField.layer.borderWidth = 0;
    
    UIAlertController *confirm = [UIAlertController
        alertControllerWithTitle:@"Confirm Changes?"
        message:@"Are you sure you want to save the changes to this task?"
        preferredStyle:UIAlertControllerStyleAlert];
    [confirm addAction:[UIAlertAction actionWithTitle:@"Cancel"
        style:UIAlertActionStyleCancel handler:nil]];
    [confirm addAction:[UIAlertAction actionWithTitle:@"Save Changes"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self saveChanges];
    }]];
    [self presentViewController:confirm animated:YES completion:nil];
}

- (void)saveChanges {
    self.task.name = [self.nameTextField.text
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.task.taskDescription = self.descriptionTextField.text ?: @"";
    
    switch (self.prioritySegmentControl.selectedSegmentIndex) {
        case 0: self.task.priority = TaskPriorityLow; break;
        case 1: self.task.priority = TaskPriorityMedium; break;
        case 2: self.task.priority = TaskPriorityHigh; break;
    }
    
    // Delete old original file if it was replaced
    if (self.originalAttachedFilePath &&
        ![self.originalAttachedFilePath isEqualToString:self.task.attachedFilePath ?: @""]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.originalAttachedFilePath error:nil];
    }
    
    [[TaskManager sharedManager] saveTasks];
    
    [self enterViewMode];
    [self populateData];
    
    UIAlertController *success = [UIAlertController
        alertControllerWithTitle:@"Saved! ✓"
        message:@"Your changes have been saved."
        preferredStyle:UIAlertControllerStyleAlert];
    [success addAction:[UIAlertAction actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:success animated:YES completion:nil];
}

- (void)cancelEditTapped {
    BOOL nameChanged = ![self.nameTextField.text isEqualToString:self.originalName];
    BOOL descChanged = ![self.descriptionTextField.text isEqualToString:
                         (self.originalDescription ?: @"")];
    
    TaskPriority currentSegPriority;
    switch (self.prioritySegmentControl.selectedSegmentIndex) {
        case 0: currentSegPriority = TaskPriorityLow; break;
        case 1: currentSegPriority = TaskPriorityMedium; break;
        default: currentSegPriority = TaskPriorityHigh; break;
    }
    BOOL priorityChanged = (currentSegPriority != self.originalPriority);
    
    // Check if file changed
    BOOL fileChanged = NO;
    NSString *currentFile = self.task.attachedFileName ?: @"";
    NSString *originalFile = self.originalAttachedFileName ?: @"";
    if (![currentFile isEqualToString:originalFile]) {
        fileChanged = YES;
    }
    
    if (nameChanged || descChanged || priorityChanged || fileChanged) {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Discard Changes?"
            message:@"You have unsaved changes. Are you sure?"
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Keep Editing"
            style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Discard"
            style:UIAlertActionStyleDestructive
            handler:^(UIAlertAction *action) {
                [self revertChanges];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self revertChanges];
    }
}

- (void)revertChanges {
    // Delete any newly picked file that wasn't saved
    if (self.task.attachedFilePath &&
        ![self.task.attachedFilePath isEqualToString:self.originalAttachedFilePath ?: @""]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.task.attachedFilePath error:nil];
    }
    
    self.task.name = self.originalName;
    self.task.taskDescription = self.originalDescription;
    self.task.priority = self.originalPriority;
    self.task.attachedFileName = self.originalAttachedFileName;
    self.task.attachedFilePath = self.originalAttachedFilePath;
    
    [self enterViewMode];
    [self populateData];
}

- (IBAction)saveEditChanges:(id)sender {
    [self doneEditingTapped];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
