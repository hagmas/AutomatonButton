//
//  AutomatonButtonViewModel.swift
//  AutomatonButton
//
//  Created by Masaki Haga on 2018/01/15.
//  Copyright © 2018 Masaki Haga. All rights reserved.
//

import Foundation

public protocol AutomatonButtonViewModel {
    associatedtype State
    associatedtype Event
    associatedtype Action
    
    static func event(with currentState: State) -> Event?
    static func reducer(for action: Action, with currentState: State) -> State?
    static func reducer(for controlEvent: UIControlEvents, with currentState: State) -> State?
}
