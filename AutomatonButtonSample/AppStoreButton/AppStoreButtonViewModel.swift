//
//  AppStoreButtonViewModel.swift
//  AutomatonButtonSample
//
//  Created by Haga Masaki on 2018/01/13.
//  Copyright © 2018 Masaki Haga. All rights reserved.
//

import Foundation
import UIKit
import AutomatonButton

struct AppStoreButtonViewModel: AutomatonButtonViewModel {
    typealias IsHighlighted = Bool
    
    enum State {
        case get(IsHighlighted)
        case loading
        case downloading(Float)
        case open(IsHighlighted)
        case startDownload(IsHighlighted)
    }
    
    enum Event {
        case getTapped
        case openTapped
        case pauseTapped
        case downloadTapped
    }
    
    enum Action {
        case apiAccessCompleted
        case apiAccessFailed
        case downloading(Float)
        case downloadCompleted
    }
    
    static func event(with currentState: State) -> Event? {
        switch currentState {
        case .get:
            return .getTapped
        case .downloading(_):
            return .pauseTapped
        case .open:
            return .openTapped
        case .startDownload:
            return .downloadTapped
        default:
            return nil
        }
    }
    
    static func reducer(for action: AppStoreButtonViewModel.Action, with currentState: State) -> AppStoreButtonViewModel.State? {
        switch action {
        case .apiAccessCompleted:
            return .downloading(0)
        case .apiAccessFailed:
            return .get(false)
        case .downloading(let proceeding):
            return .downloading(proceeding)
        case .downloadCompleted:
            return .open(false)
        }
    }
    
    static func reducer(for controlEvent: UIControlEvents, with currentState: State) -> AppStoreButtonViewModel.State? {
        if controlEvent == .touchUpInside {
            switch currentState {
            case .get, .startDownload:
                return .loading
            case .downloading(_):
                return .startDownload(false)
            case .open(let isHighlighted) where isHighlighted:
                return .open(false)
            default:
                return nil
            }
        } else if controlEvent == .touchDown {
            switch currentState {
            case .get(let isHighlighted) where !isHighlighted:
                return .get(true)
            case .startDownload(let isHighlighted) where !isHighlighted:
                return .startDownload(true)
            case .open(let isHighlighted) where !isHighlighted:
                return .open(true)
            default:
                return nil
            }
        } else if controlEvent == .touchUpOutside {
            switch currentState {
            case .get(let isHighlighted) where isHighlighted:
                return .get(false)
            case .startDownload(let isHighlighted) where isHighlighted:
                return .startDownload(false)
            case .open(let isHighlighted) where isHighlighted:
                return .open(false)
            default:
                return nil
            }
        }
        return nil
    }
}
