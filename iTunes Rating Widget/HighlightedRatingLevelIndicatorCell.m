//
//  HighlightedRatingLevelIndicatorCell.m
//  iTunes Rating
//
//  Created by Genji on 2015/02/07.
//  Copyright (c) 2015 Genji App. All rights reserved.
//

#import "HighlightedRatingLevelIndicatorCell.h"

@implementation HighlightedRatingLevelIndicatorCell

- (BOOL)isHighlighted
{
  return YES;
}

- (NSLevelIndicatorStyle)levelIndicatorStyle
{
  return NSRatingLevelIndicatorStyle;
}

@end
