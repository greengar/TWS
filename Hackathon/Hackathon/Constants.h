//
//  Constants.h
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Hackathon_Constants_h
#define Hackathon_Constants_h

#define GAME_LENGTH_SECONDS 5 // number of seconds for a game play
#define MONSTER_EVERY_X_SECONDS 5 // for now
#define MONSTER_MOVE_EVERY_X_SECONDS 3.0 // for now
#define MONSTER_MOVE_DURATION_SECONDS 30.0 // seconds
#define INITIAL_POINTS 50.0; // how much a monster kill is worth initially
#define POINT_DECREASE_VALUE 5.0;
#define STAR_THROW_TIME 0.5
#define BLOOD_MOVE_DURATION_SECONDS 1.5
#define BOSS_APPEARS_AT_TIME_LEFT 10.0
#define BOSS_INITIAL_POINTS 200
#define FIREBALL_EVERY_X_SECONDS 7.0 // for now
#define FIREBALL_MOVE_DURATION_SECONDS 10.0 // seconds
#define NINJA_WALK_ON_SCREEN_TIME 0.5 // remote ninjas showing up animation

typedef enum {
    kGameOverTimeOut=1,
    kGameOverEaten
} GameOverReasonType;

#endif
