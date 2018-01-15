//
//  AutomatonButton.swift
//  AutomatonButton
//
//  Created by Masaki Haga on 2018/01/15.
//  Copyright © 2018 Masaki Haga. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxOptional

open class AutomatonButton<T: AutomatonButtonViewModel>: UIControl {
    private let disposeBag = DisposeBag()
    
    public enum InternalAction {
        case fromOutside(T.Action)
        case fromUIControl(UIControlEvents)
    }
    
    // This is to override
    open var animations: Binder<(T.State?, T.State)> {
        return Binder<(T.State?, T.State)>(self, binding: { (target, stateSet) in
        })
    }
    
    private let _customState: Variable<T.State>
    public var customState: Observable<T.State> {
        return _customState.asObservable()
    }
    private let actionHub = PublishSubject<InternalAction>()
    private let eventPublisher = PublishSubject<T.Event>()
    
    public init(initialState: T.State) {
        _customState = Variable(initialState)
        
        super.init(frame: .zero)
        
        let tapEvent = rx.controlEvent(.touchUpInside)
        
        sampling(hoge: tapEvent.asObservable(), source: _customState)
            .map { $1 }
            .map (T.event)
            .filterNil().bind(to: eventPublisher).disposed(by: disposeBag)
        
        tapEvent.map { event in InternalAction.fromUIControl(.touchUpInside) }.bind(to: actionHub).disposed(by: disposeBag)
        rx.controlEvent(.touchDown).map { event in InternalAction.fromUIControl(.touchDown) }.bind(to: actionHub).disposed(by: disposeBag)
        rx.controlEvent(.touchUpOutside).map { event in InternalAction.fromUIControl(.touchUpOutside) }.bind(to: actionHub).disposed(by: disposeBag)
        
        Observable.zip(_customState.asObservable().map { Optional($0) }.startWith(nil), _customState.asObservable())
            .bind(to: animations).disposed(by: disposeBag)
        
        sampling(hoge: actionHub.asObservable(), source: _customState)
            .map({ (internalAction, state) -> T.State? in
                switch internalAction {
                case .fromOutside(let action):
                    return T.reducer(for: action, with: state)
                case .fromUIControl(let controlEvents):
                    return T.reducer(for: controlEvents, with: state)
                }
            }).filterNil().bind(to: _customState).disposed(by: disposeBag)
    }
    
    private func sampling<S>(hoge: Observable<S>, source: Variable<T.State>) -> Observable<(S, T.State)> {
        return hoge.map { internalAction -> (S, T.State) in
            return (internalAction, source.value)
        }
    }
    
    public var actionObserver: AnyObserver<T.Action> {
        return actionHub.asObserver().mapObserver { (inputAction: T.Action) -> InternalAction in
            return InternalAction.fromOutside(inputAction)
        }
    }
    
    public var event: ControlEvent<T.Event> {
        return ControlEvent(events: eventPublisher)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
