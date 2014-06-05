//
//  StateMachine.swift
//  KSwift
//
//  Created by Adam Roth on 6/5/14.
//  Copyright (c) 2014 Adam Roth, Inc. All rights reserved.
//
//  Port of impactjs-statemachine (https://github.com/drhayes/impactjs-statemachine)
//      with transitional animation enhnacements. Thanks David.
//
import Foundation
import SpriteKit

class StateMachine {
    
    var initialState: String?
    var currentState: String?
    var previousState: String?
    var states = Dictionary<String, State>()
    var transitions = Dictionary<String, StateMachineTransition>()
    var lastTransition: StateMachineTransition?
    var entity: Character!
    var history:String[] = [];
    
    init(){
    }
    
    func setEntity(entity:Character){
        self.entity = entity;
    }
    
    func addState(name:String, enter: (()->Void), update: (()->Void), exit: (()->Void)) {
        self.states[ name ] = State(name: name, enter: enter, update: update, exit: exit);
        if !self.initialState {
            self.initialState = name
            self.currentState = name
        }
    }
    
    func getState(name:String) -> State {
        return self.states[ name ]!
    }
    
    
    func addTransition(name: String, fromState: String, toState: String, predicate: (()->Bool)){
        if( self.states[ fromState ] == nil ){
            NSLog("Missing from state: %@", fromState);
        }
        
        
        if( self.states[ toState ] == nil ){
            NSLog("Missing to state: %@", toState);
        }
        
        var transition = StateMachineTransition(name: name, fromState: fromState, toState: toState, predicate: predicate)
        
        self.transitions[ name ] = transition
    }
    
    func getTransition(name:String) -> StateMachineTransition {
        return self.transitions[ name ]!
    }
    
    func update(){
        if( self.currentState == nil ){
            self.currentState = self.initialState;
        }
        
        var state = self.getState(self.currentState!);
        
        if( self.previousState != self.currentState ){
            
            if( self.entity.anims.count > 0 ){
                
                if( self.lastTransition != nil && self.entity.anims[ self.lastTransition!.name ] ){
                    
                    // Transitional Animation
                    self.entity.currentAnim = self.entity.anims[ self.lastTransition!.name ]?;
                    self.entity.sprite.runAction( SKAction.repeatAction( SKAction.animateWithTextures(self.entity.anims[ self.lastTransition!.name]?.frames, timePerFrame: 0.05), count: 1), completion: {
                        
                        
                        if( state.enter != nil ){
                            state.enter(); // self.lastTransition
                            self.entity.currentAnim = self.entity.anims[ self.currentState! ]
                            
                            
                            // Enter Animation
                            self.entity.sprite.runAction( SKAction.repeatActionForever( SKAction.animateWithTextures(self.entity.anims[ self.currentState! ]?.frames, timePerFrame: 0.07)))
                            
                        }
                    });
                    
                }else{
                    if( state.enter != nil ){
                        state.enter(); // self.lastTransition
                        
                        // Enter animation
                        self.entity.currentAnim = self.entity.anims[ self.currentState! ]
                        self.entity.sprite.runAction( SKAction.repeatActionForever( SKAction.animateWithTextures(self.entity.anims[ self.currentState! ]?.frames, timePerFrame: 0.07)))
                        
                    }
                }
            }
            
            self.previousState = self.currentState;
            self.history += self.currentState!;
        }
        
        
        if( state.update != nil ){
            state.update();
        }
        
        // Interate through transitions
        for t_struct in transitions {
            var name = t_struct.0;
            var transition = t_struct.1;
            
            if( transition.fromState == self.currentState && transition.predicate() ){
                self.lastTransition = transition;
                
                
                if( state.exit != nil ){
                    state.exit();
                }
                
                self.currentState = transition.toState;
            }
        }
    }
    
}

struct State {
    var name: String
    var enter: (()->Void)
    var update: (()->Void)
    var exit: (()->Void)
}

struct StateMachineTransition {
    var name: String
    var fromState: String
    var toState: String
    var predicate: (()->Bool)
}