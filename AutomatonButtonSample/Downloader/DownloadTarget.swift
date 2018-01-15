//
//  DownloadTarget.swift
//  AutomatonButtonSample
//
//  Created by Haga Masaki on 2017/12/14.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation

protocol DownloadTarget {
    var URLString: String { get }
    var saveURLString: String { get }
    var startBlock: (() -> Void)? { get }
    var completeBlock: (() -> Void)? { get }
    var failureBlock: ((Error?) -> Void)? { get }
    var cancelBlock: (() -> Void)? { get }
    var progressBlock: ((Float) -> Void)? { get }
}
