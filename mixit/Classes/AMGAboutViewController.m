//
//  AMGAboutViewController.m
//  mixit
//
//  Created by Vincent Tourraine on 26/03/15.
//  Copyright (c) 2015-2016 Studio AMANgA. All rights reserved.
//

#import "AMGAboutViewController.h"

#import "AMGMixITClient.h"
#import "AMGTalksViewController.h"

@import MapKit;
@import CoreLocation;
@import SafariServices;


@interface AMGAboutViewController () <CLLocationManagerDelegate>

@property (nonatomic, assign) CLLocationCoordinate2D coordinates;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong, nullable) NSArray <NSNumber *> * pastYears;

- (void)loadNavigationItems;
- (void)loadHeaderView;
- (void)loadFooterView;

@end


static NSString * const AMGButtonCellIdentifier = @"Cell";

NS_ENUM(NSUInteger, AMGAboutSections) {
    AMGAboutMapSection,
    AMGAboutLinksSection,
    AMGAboutPastYearsSection
};

NS_ENUM(NSUInteger, AMGMapRows) {
    AMGMapOpenInMapsRow
};


@implementation AMGAboutViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];

    if (self) {
        self.title = NSLocalizedString(@"About Mix-IT", nil);
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pastYears = [AMGMixITClient pastYears];

    [self loadNavigationItems];
    [self loadHeaderView];
    [self loadFooterView];

    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:AMGButtonCellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization]; // iOS 8+ only
    }
}

- (void)loadNavigationItems {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:NSLocalizedString(@"Close", nil)
                                             style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(dismiss:)];
}

- (void)loadHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];

    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];
    logoView.frame = CGRectMake((CGRectGetWidth(headerView.frame) - CGRectGetWidth(logoView.frame))/2, 2*20,
                                CGRectGetWidth(logoView.frame), CGRectGetHeight(logoView.frame));
    logoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [headerView addSubview:logoView];

    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logoView.frame) + 8, CGRectGetWidth(headerView.frame), 80)];
    dateLabel.font = [UIFont boldSystemFontOfSize:20];
    dateLabel.numberOfLines = 2;
    dateLabel.text = NSLocalizedString(@"April 21 and 22, 2016\nLyon, France", nil);
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [headerView addSubview:dateLabel];

    self.coordinates = CLLocationCoordinate2DMake(45.78392, 4.869014);

    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dateLabel.frame) + 20,
                                                                     CGRectGetWidth(headerView.frame), 200)];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.coordinates;
    annotation.title      = NSLocalizedString(@"Mix-IT", nil);
    annotation.subtitle   = NSLocalizedString(@"CPE Lyon", nil);
    [mapView addAnnotation:annotation];
    mapView.region = MKCoordinateRegionMake(self.coordinates, MKCoordinateSpanMake(0.05, 0.05));
    [headerView addSubview:mapView];
    self.mapView = mapView;

    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(mapView.frame),
                                                                 CGRectGetWidth(headerView.frame), 1/[UIScreen mainScreen].scale)];
    topBorder.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
    topBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [headerView addSubview:topBorder];

    headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMaxY(mapView.frame));
    self.tableView.tableHeaderView = headerView;
}

- (void)loadFooterView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 150)];
    label.numberOfLines = 0;
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.userInteractionEnabled = YES;
    label.text = NSLocalizedString(@"This app isn’t affiliated with the Mix-IT team.\n"
                                   @"Made by @vtourraine.", nil);
    self.tableView.tableFooterView = label;

    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openVTourraine:)];
    recognizer.numberOfTapsRequired = 1;
    [label addGestureRecognizer:recognizer];
}


#pragma mark - Actions

- (IBAction)openInMaps:(id)sender {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinates addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = NSLocalizedString(@"Mix-IT", nil);

    [item openInMapsWithLaunchOptions:@{MKLaunchOptionsMapCenterKey: [NSValue valueWithMKCoordinate:self.coordinates]}];
}

- (IBAction)openInSafari:(id)sender {
    [self openURLString:@"http://www.mix-it.fr/"];
}

- (IBAction)openVTourraine:(id)sender {
    [self openURLString:@"http://www.vtourraine.net?mixit"];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openURLString:(nonnull NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:URLString];

    if ([SFSafariViewController class]) {
        SFSafariViewController *viewController = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else {
        [[UIApplication sharedApplication] openURL:URL];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case AMGAboutMapSection:
        case AMGAboutLinksSection:
            return 1;

        case AMGAboutPastYearsSection:
            return self.pastYears.count;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AMGButtonCellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case AMGAboutMapSection:
        case AMGAboutLinksSection:
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.textLabel.textColor = self.view.tintColor;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;

        case AMGAboutPastYearsSection:
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.textLabel.textColor = [UIColor darkTextColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
    }

    switch (indexPath.section) {
        case AMGAboutMapSection:
            cell.textLabel.text = NSLocalizedString(@"Open in Maps", nil);
            break;

        case AMGAboutLinksSection:
            cell.textLabel.text = NSLocalizedString(@"Open Mix-IT website", nil);
            break;

        case AMGAboutPastYearsSection:
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Mix-IT %@", nil),
                                   self.pastYears[indexPath.row]];
            break;
    }

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case AMGAboutMapSection:
            [self openInMaps:nil];
            break;

        case AMGAboutLinksSection:
            [self openInSafari:nil];
            break;

        case AMGAboutPastYearsSection:
            [self presentTalksViewControllerForYear:self.pastYears[indexPath.row]];
            break;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)presentTalksViewControllerForYear:(nonnull NSNumber *)year {
    AMGTalksViewController *viewController = [[AMGTalksViewController alloc] init];
    viewController.syncManager = self.syncManager;
    viewController.year = year;

    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
    }
}

@end
