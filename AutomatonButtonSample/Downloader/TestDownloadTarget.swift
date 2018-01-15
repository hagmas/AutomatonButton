//
//  TestDownloadTarget.swift
//  AutomatonButtonSample
//
//  Created by Masaki Haga on 2018/01/10.
//  Copyright © 2018 Masaki Haga. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TestDownloadTarget: DownloadTarget {
    let URLString: String = "https://devstreaming-cdn.apple.com/videos/wwdc/2017/818xw12wzot6au/818/818_sd_60_second_prototyping.mp4?dl=1"
    var saveURLString: String {
        guard let url = URL(string: URLString) else {
            return ""
        }
        let fileName = url.lastPathComponent
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
        return (paths[0] as NSString).appendingPathComponent(fileName)
    }
    
    var startBlock: (() -> Void)? = nil
    var completeBlock: (() -> Void)? = nil
    var failureBlock: ((Error?) -> Void)? = nil
    var progressBlock: ((Float) -> Void)? = nil
    var cancelBlock: (() -> Void)? = nil
    
    var actionPublisher: Observable<AppStoreButtonViewModel.Action> {
        return Observable.create({ [weak self] observer -> Disposable in
            guard let weakSelf = self else {
                return Disposables.create()
            }
            
            weakSelf.startBlock = {
                DispatchQueue.main.async {
                    observer.onNext(.apiAccessCompleted)
                }
            }
            
            weakSelf.progressBlock = { progress in
                DispatchQueue.main.async {
                    observer.onNext(.downloading(progress))
                }
            }
            
            weakSelf.completeBlock = {
                DispatchQueue.main.async {
                    observer.onNext(.downloadCompleted)
                }
            }
            
            return Disposables.create()
        })
    }
}
