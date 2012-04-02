//
//  BombSelector.h
//  Doomsday Area
//
//  Created by Vladimir Smirnov on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BombSelector : UITableViewController
{
    NSMutableArray *listOfMovies;
    NSMutableArray *ListOfBombs;
}

@property (assign,nonatomic) NSArray *BombsList;
@property (assign,nonatomic) NSInteger SelectedBombID;


@end
