//
//  TodayViewController.m
//  iTunes Rating Widget
//
//  Created by Genji on 2015/02/05.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import <NotificationCenter/NotificationCenter.h>
#import "TodayViewController.h"
#import "iTunes.h"

static NSString * const kITunesBundleIdentifier = @"com.apple.iTunes";
static NSString * const kITunesDistributedNotificationName = @"com.apple.iTunes.playerInfo";

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, readonly) iTunesApplication *iTunesApp;

@property (nonatomic, weak) IBOutlet NSImageView *artworkImageView;
@property (nonatomic, weak) IBOutlet NSTextField *trackNameLabel;
@property (nonatomic, weak) IBOutlet NSTextField *artistNameAndAlbumNameLabel;
@property (nonatomic, weak) IBOutlet NSLevelIndicator *ratingLevelIndicator;

- (IBAction)ratingDidChange:(id)sender;

@end

@implementation TodayViewController

- (void)viewWillAppear
{
  [super viewWillAppear];

  [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(didCatchITunesNotification:) name:kITunesDistributedNotificationName object:nil];
  [self updateView];
}

- (void)viewWillDisappear
{
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:kITunesDistributedNotificationName object:nil];

  [super viewWillDisappear];
}


#pragma mark -
#pragma mark Private Method
- (void)didCatchITunesNotification:(NSNotification *)notification
{
  [self updateView];
}

- (void)updateView
{
  // iTunesApp.currentTrack.persistentID 等の実行まで行くと、未起動状態の iTunes が起動してしまう。
  // iTunesApplication オブジェクトの生成、iTunesApp.running、iTunesApp.currentTrack の
  // 実行まではOK。

  iTunesTrack *track = self.iTunesApp.currentTrack;
  if(self.iTunesApp.running && track.persistentID) {
    self.view.hidden = NO;

    NSString *trackName = track.name;
    NSString *artistName = track.artist;
    NSString *albumName = track.album;
    self.trackNameLabel.stringValue = trackName ? trackName : @"";
    self.artistNameAndAlbumNameLabel.stringValue = [NSString stringWithFormat:@"%@%@%@", artistName ? artistName : @"", (artistName.length && albumName.length) ? @" - " : @"", albumName ? albumName : @""];

    self.ratingLevelIndicator.integerValue = track.rating / 20;

    iTunesArtwork *artwork = track.artworks[0];
    // artwork.data が NSImage を返してくれるはずだが、アートワークが PNG で登録されている場合には、
    // なぜか NSImage ではなく NSAppleEventDescriptor オブジェクトを返してくるので、
    // artwork.rawData から NSImage を生成する。
    NSImage *artworkImage = [[NSImage alloc] initWithData:artwork.rawData];
    if(!artworkImage) {
      NSImage *placeholder = [NSImage imageNamed:@"ArtworkPlaceholder"];
      artworkImage = placeholder;
    }
    self.artworkImageView.image = artworkImage;
  }
  else {
    self.view.hidden = YES;
  }
}


#pragma mark -
#pragma mark Accessor Method
- (iTunesApplication *)iTunesApp
{
  static iTunesApplication *iTunesApp = nil;
  if(!iTunesApp) {
    iTunesApp = [SBApplication applicationWithBundleIdentifier:kITunesBundleIdentifier];
  }
  return iTunesApp;
}


#pragma mark -
#pragma mark Action Method
- (IBAction)ratingDidChange:(id)sender
{
  iTunesTrack *track = self.iTunesApp.currentTrack;
  if(self.iTunesApp.running && track.persistentID) {
    NSLevelIndicator *ratingLevelIndicator = (NSLevelIndicator *)sender;
    track.rating = ratingLevelIndicator.integerValue * 20;
  }
}


#pragma mark -
#pragma mark NCWidgetProviding Method
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler
{
  [self updateView];

  completionHandler(NCUpdateResultNewData);
}

@end

