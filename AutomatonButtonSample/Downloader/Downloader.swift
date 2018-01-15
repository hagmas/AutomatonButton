//
//  Downloader.swift
//  AutomatonButtonSample
//
//  Created by Haga Masaki on 2017/12/14.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation
import UIKit

private extension DownloadTarget {
    func resumeDataPath(directory: String) -> String {
        return (directory as NSString).appendingPathComponent(URLString.md5)
    }
}

class Downloader: NSObject {
    static let resumeDataDirectory: String = {
        var temp = NSTemporaryDirectory()
        let path = (temp as NSString).appendingPathComponent("ResumeData")
        return path
    }()
    
    static let shared = Downloader()
    private var session: URLSession?
    private var targets = [URLSessionDownloadTask: DownloadTarget]()
    
    private override init() {
        super.init()
        
        // create folder for resume data
        let resumeDataPath = Downloader.resumeDataDirectory
        if !FileManager.default.fileExists(atPath: resumeDataPath) {
            do {
                try FileManager.default.createDirectory(atPath: resumeDataPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create directory \(resumeDataPath)")
            }
        }
        
        let config = URLSessionConfiguration.background(withIdentifier: "hoge")
        config.sessionSendsLaunchEvents = true
        config.isDiscretionary = true
        config.httpMaximumConnectionsPerHost = 1
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    func download(target: DownloadTarget) {
        if let url = URL(string: target.URLString),
            let task = self.session?.downloadTask(with: url) {
            target.startBlock?()
            task.resume()
            targets[task] = target
        } else {
            target.failureBlock?(nil)
        }
    }
    
    func stop(target: DownloadTarget) {
        guard let task = targets.filter( { $1.URLString == target.URLString } ).first else {
            return
        }
        task.key.cancel(byProducingResumeData: { resumeData in
            let resumeDataPath = target.resumeDataPath(directory: Downloader.resumeDataDirectory)
            let hoge = FileManager.default.createFile(atPath: resumeDataPath, contents: resumeData, attributes: nil)
            print((hoge == true) ? "Success to save" : "failed to save")
        })
        targets.removeValue(forKey: task.key)
    }
    
    func resume(target: DownloadTarget) {
        let resumeDataPath = target.resumeDataPath(directory: Downloader.resumeDataDirectory)
        if let resumeData = FileManager.default.contents(atPath: resumeDataPath) {
            do {
                try FileManager.default.removeItem(atPath: resumeDataPath)
            } catch {
                print("\(error)")
            }
            
            guard let task = session?.downloadTask(withResumeData: resumeData) else {
                return
            }
            task.resume()
            targets[task] = target
        } else {
            download(target: target)
        }
    }
    
    func remove(target: DownloadTarget) {
        guard let task = targets.filter( { $1.URLString == target.URLString } ).first else {
            return
        }
        task.key.cancel()
        targets.removeValue(forKey: task.key)
    }
    
    func cancelAll() {
        for (key, value) in targets {
            key.cancel(byProducingResumeData: { resumeData in
                let resumeDataPath = value.resumeDataPath(directory: Downloader.resumeDataDirectory)
                FileManager.default.createFile(atPath: resumeDataPath, contents: resumeData, attributes: nil)
            })
        }
        targets = [:]
    }
}

extension Downloader: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? URLSessionDownloadTask, let target = targets[downloadTask] else {
            return
        }
        
        if let error = error {
            target.failureBlock?(error)
            targets.removeValue(forKey: downloadTask)
        }
    }
}

extension Downloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let target = targets[downloadTask], let data = try? Data(contentsOf: location) {
            FileManager.default.createFile(atPath: target.saveURLString, contents: data, attributes: nil)
            target.completeBlock?()
            targets.removeValue(forKey: downloadTask)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {        
        guard let target = targets[downloadTask] else {
            return
        }
        target.progressBlock?(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
    }
}
