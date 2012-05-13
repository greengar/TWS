//
//  Constants.h
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Hackathon_Constants_h
#define Hackathon_Constants_h

#define GAME_LENGTH_SECONDS 120 // number of seconds for a game play
#define MONSTER_EVERY_X_SECONDS 2.5 // for now
#define MONSTER_MOVE_EVERY_X_SECONDS 3.0 // for now
#define MONSTER_MOVE_DURATION_SECONDS 5.0 // seconds
#define INITIAL_POINTS 50.0; // how much a monster kill is worth initially
#define POINT_DECREASE_VALUE 5.0;
#define STAR_THROW_TIME 0.5
#define BLOOD_MOVE_DURATION_SECONDS 1.5

typedef enum {
    kGameOverTimeOut=1,
    kGameOverEaten
} GameOverReasonType;

#endif
