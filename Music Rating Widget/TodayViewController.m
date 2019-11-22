//
//  TodayViewController.m
//  Music Rating Widget
//
//  Created by Genji on 2015/02/05.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import <NotificationCenter/NotificationCenter.h>
#import "TodayViewController.h"
#import "Music.h"

static NSString * const kMusicBundleIdentifier = @"com.apple.Music";
static NSString * const kMusicDistributedNotificationName = @"com.apple.Music.playerInfo";

@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, readonly) MusicApplication *MusicApp;

@property (nonatomic, weak) IBOutlet NSTextField *trackNameLabel;
@property (nonatomic, weak) IBOutlet NSTextField *artistNameAndAlbumNameLabel;
@property (nonatomic, weak) IBOutlet NSLevelIndicator *ratingLevelIndicator;
@property (nonatomic, weak) IBOutlet NSButton *artworkImageButton;

- (IBAction)ratingDidChange:(id)sender;
- (IBAction)togglePlayPause:(id)sender;

@end

@implementation TodayViewController

- (void)viewWillAppear
{
  [super viewWillAppear];

  [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(didCatchMusicNotification:) name:kMusicDistributedNotificationName object:nil];
  [self updateView];
}

- (void)viewWillDisappear
{
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:kMusicDistributedNotificationName object:nil];

  [super viewWillDisappear];
}


#pragma mark -
#pragma mark Private Method
- (void)didCatchMusicNotification:(NSNotification *)notification
{
  [self updateView];
}

- (void)updateView
{
  // MusicApp.currentTrack.persistentID 等の実行まで行くと、未起動状態の Music が起動してしまう。
  // MusicApplication オブジェクトの生成、MusicApp.running、MusicApp.currentTrack の
  // 実行まではOK。
  MusicTrack *track = self.MusicApp.currentTrack;
  if(self.MusicApp.running && track.persistentID) {
    self.view.hidden = NO;

    NSString *trackName = track.name;
    NSString *artistName = track.artist;
    NSString *albumName = track.album;
    self.trackNameLabel.stringValue = trackName ? trackName : @"";
    self.artistNameAndAlbumNameLabel.stringValue = [NSString stringWithFormat:@"%@%@%@", artistName ? artistName : @"", (artistName.length && albumName.length) ? @" - " : @"", albumName ? albumName : @""];
    self.ratingLevelIndicator.integerValue = track.rating / 20;

    NSImage *artworkImage = nil;
    MusicArtwork *artwork = track.artworks[0];
    if([artwork.data isKindOfClass:[NSImage class]]) {
      artworkImage = artwork.data;
    }
    // アートワークがPNG形式のとき、NSImage であるはずの data プロパティが NSAppleEventDescriptor オブジェクトを返してくる。
    // そのとき、その NSAppleEventDescriptor オブジェクトの data プロパティに画像の生データが入っている。
    // iTunes時代は rawData プロパティに NSData で生データが入っていたが、それも SBObject が返ってきて変。
    else if([artwork.data isKindOfClass:[NSAppleEventDescriptor class]]) {
      NSData *data = [(NSAppleEventDescriptor *)artwork.data data];
      artworkImage = [[NSImage alloc] initWithData:data];
    }
    // rawData プロパティが NSData であることがない？　常に SBObject オブジェクトが返ってくる。
    // したがって、この else if 内の処理が実行されることはない。
    else if([artwork.rawData isKindOfClass:[NSDate class]]) {
      artworkImage = [[NSImage alloc] initWithData:artwork.rawData];
    }
    else {
      artworkImage = [NSImage imageNamed:@"ArtworkPlaceholder"];
    }
    self.artworkImageButton.image = artworkImage;
  }
  else {
    self.view.hidden = YES;
  }
}


#pragma mark -
#pragma mark Accessor Method
- (MusicApplication *)MusicApp
{
  static MusicApplication *MusicApp = nil;
  if(!MusicApp) {
    MusicApp = [SBApplication applicationWithBundleIdentifier:kMusicBundleIdentifier];
  }
  return MusicApp;
}


#pragma mark -
#pragma mark Action Method
- (IBAction)ratingDidChange:(id)sender
{
  MusicTrack *track = self.MusicApp.currentTrack;
  if(self.MusicApp.running && track.persistentID) {
    NSLevelIndicator *ratingLevelIndicator = (NSLevelIndicator *)sender;
    track.rating = ratingLevelIndicator.integerValue * 20;
  }
}

- (IBAction)togglePlayPause:(id)sender
{
  [self.MusicApp playpause];
}


#pragma mark -
#pragma mark NCWidgetProviding Method
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler
{
  [self updateView];

  completionHandler(NCUpdateResultNewData);
}

@end

