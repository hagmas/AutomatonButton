//
//  ViewController.swift
//  AutomatonButtonSample
//
//  Created by Masaki Haga on 2018/01/15.
//  Copyright © 2018 Masaki Haga. All rights reserved.
//

import UIKit
import AutomatonButton
import RxSwift
import RxCocoa
import AVKit

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statefulButton = AppStoreButton(initialState: .get(false))
        view.addSubview(statefulButton)
        
        statefulButton.translatesAutoresizingMaskIntoConstraints = false
        statefulButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        statefulButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let testTarget = TestDownloadTarget()
        testTarget.actionPublisher.bind(to: statefulButton.actionObserver).disposed(by: disposeBag)
        
        statefulButton.event.subscribe(onNext: { [weak self] event in
            switch event {
            case .getTapped:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    Downloader.shared.download(target: testTarget)
                })
                
            case .pauseTapped:
                Downloader.shared.stop(target: testTarget)
                
            case .downloadTapped:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    Downloader.shared.resume(target: testTarget)
                })
                
            case .openTapped:
                // open the video
                let vc = AVPlayerViewController()
                vc.player = AVPlayer(url: URL(fileURLWithPath: testTarget.saveURLString))
                self?.present(vc, animated: true, completion: nil)
            }
        }).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

