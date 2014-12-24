//
//  BERegisterController.m
//  badEgg
//
//  Created by lilin on 13-11-13.
//  Copyright (c) 2013年 surekam. All rights reserved.
//

#import "BERegisterController.h"

@interface BERegisterController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIButton *buttonWithBackgroundImage;

@end

@implementation BERegisterController
@synthesize imagePickerDelegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)reback
{
    //返回
    [self dismissViewControllerAnimated:YES completion:^{
    
    }];
}

- (void)goRegister
{
    //注册
}

- (void)getPhotos
{
    UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择",@"从拍摄选择", nil];
    [photoSheet showInView:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableview.layer.cornerRadius=6;
    _tableview.layer.masksToBounds=YES;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"savedImage"]) { // test cached image
        NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedImage"];
        UIImage *cachedImage = [NSData imageFromFile:[[[NSFileManager defaultManager] cacheDataPath] stringByAppendingPathComponent:urlString]];
        if (cachedImage) {
            [self setOriginalImage:[UIImage imageNamed:@"camera"] resizedImage:cachedImage];
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"registerCell%ld",(long)indexPath.row]];

    return cell;
}

- (IBAction)presentPhotoPicker
{
    if (!imagePickerDelegate) {
        self.imagePickerDelegate = [[EIImagePickerDelegate alloc] init];
        
        __weak BERegisterController *weakController = self;
        [imagePickerDelegate setImagePickerCompletionBlock:^(UIImage *pickerImage) {
            
            __strong BERegisterController *strongController = weakController;
            
            NSLog(@"logical size is %f:%f scale %f", pickerImage.size.width, pickerImage.size.height, pickerImage.scale);
            UIImage *resizedImage = [pickerImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(80, 80) interpolationQuality:kCGInterpolationDefault];
            
            // Use uncompressed size to constrain resizing
            //            UIImage *resizedImage = [pickerImage resizedImageWithUncompressedSizeInMB:1.0 interpolationQuality:kCGInterpolationDefault];
     
            [strongController setOriginalImage:pickerImage resizedImage:resizedImage];
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"savedImage"]) {
                NSString *cachedFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedImage"];
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL URLWithString:cachedFilePath] error:NULL];
            }
            
            NSString *assetName = [NSString stringWithFormat:@"%@.png", [[NSProcessInfo processInfo]     globallyUniqueString]];
            assetName = [assetName stringByAppendingScaleSuffix]; // add scale suffix to extension
            NSString *assetPath     = [[[NSFileManager defaultManager] cacheDataPath] stringByAppendingPathComponent:assetName];
            
            // saving synchronously
            //            [UIImagePNGRepresentation(resizedImage) writeToFile:assetPath atomically:NO];
            //            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", assetName] forKey:@"savedImage"];
            
            [[EIOperationManager defaultManager] saveImage:resizedImage toPath:assetPath withBlock:^(BOOL success) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", assetName] forKey:@"savedImage"];
            }];
            
        }];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册", @"相机", nil];
        [actionSheet showInView:self.view];
        
    } else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册", nil];
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [imagePickerDelegate presentFromController:self withSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 1:
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [imagePickerDelegate presentFromController:self withSourceType:UIImagePickerControllerSourceTypeCamera];
            }
            break;
        default:
            break;
    }
}

- (void)setOriginalImage:(UIImage *)aImage resizedImage:(UIImage *)bImage
{
    [_buttonWithBackgroundImage setBackgroundImage:bImage forState:UIControlStateNormal];
}
@end
