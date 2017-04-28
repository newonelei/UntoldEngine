//
//  U11PlayerAttackFormationState.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 4/26/17.
//  Copyright © 2017 Untold Game Studio. All rights reserved.
//

#include "U11PlayerAttackFormationState.h"
#include "U11PlayerIdleState.h"

U11PlayerAttackFormationState* U11PlayerAttackFormationState::instance=0;

U11PlayerAttackFormationState::U11PlayerAttackFormationState(){
    
}

U11PlayerAttackFormationState::~U11PlayerAttackFormationState(){
    
}

U11PlayerAttackFormationState* U11PlayerAttackFormationState::sharedInstance(){
    
    if (instance==0) {
        instance=new U11PlayerAttackFormationState();
    }
    
    return instance;
    
}

void U11PlayerAttackFormationState::enter(U11Player *uPlayer){
    
    uPlayer->setNextAnimationToPlay(uPlayer->getRunningAnimation());
    uPlayer->setPlayBlendedAnimation(true);
    uPlayer->setPlayNextAnimationContinuously(true);
    
}

void U11PlayerAttackFormationState::execute(U11Player *uPlayer, double dt){
    
    U4DEngine::U4DPoint3n formationPosition=uPlayer->getFormationPosition();
    
    uPlayer->seekPosition(formationPosition);
    
    if (!uPlayer->hasReachedPosition(formationPosition,withinDefenseDistance)) {
        
        //make the player run
        uPlayer->applyForceToPlayer(chasingSpeed, dt);
        
    }else{
        
        uPlayer->removeAllVelocities();
        uPlayer->removeKineticForces();
        
        uPlayer->changeState(U11PlayerIdleState::sharedInstance());
        
    }
    
}

void U11PlayerAttackFormationState::exit(U11Player *uPlayer){
    
}

bool U11PlayerAttackFormationState::isSafeToChangeState(U11Player *uPlayer){
    
    return true;
}

bool U11PlayerAttackFormationState::handleMessage(U11Player *uPlayer, Message &uMsg){
    
    
    return false;
    
}