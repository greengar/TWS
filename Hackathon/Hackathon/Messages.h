//
//  Messages.h
//  Hackathon
//
//  Created by Eran Davidov on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Hackathon_Messages_h
#define Hackathon_Messages_h

typedef enum {
    kMessageJoinRequest=1, // join a game, ask for a monster dump
    kMessageMonsterBorn,
    kMessageMonsterDead,
    kMessagePlayerDied,
    kMessagePlayerLeft,
} PeerMessageType;

#define MESSAGE_TYPE @"MessageType"

#endif
