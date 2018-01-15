//
//  AppStoreButton.swift
//  AutomatonButtonSample
//
//  Created by Haga Masaki on 2018/01/13.
//  Copyright © 2018 Masaki Haga. All rights reserved.
//

import Foundation
import UIKit
import AutomatonButton
import RxCocoa
import RxSwift

class AppStoreButton: AutomatonButton<AppStoreButtonViewModel> {
    // UI elements
    private let text = UILabel(frame: CGRect(x: 0, y: 0, width: 74, height: 30))
    
    private let shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0, width: 74, height: 30)
        return shapeLayer
    }()
    
    class DownloadMeterLayer: CAShapeLayer {
        private let proceedingLayer: CAShapeLayer = {
            let layer = CAShapeLayer()
            layer.strokeColor = Color.blue.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 2.0
            layer.path = Path.circle.cgPath
            layer.strokeEnd = 0.0
            return layer
        }()
        
        private let stopMarkLayer: CAShapeLayer = {
            let layer = CAShapeLayer()
            layer.path = Path.stopMark.cgPath
            layer.fillColor = Color.blue.cgColor
            return layer
        }()
        
        init(frame: CGRect) {
            super.init()
            
            self.frame = frame
            strokeColor = Color.darkGray.cgColor
            fillColor = UIColor.white.cgColor
            lineWidth = 2.0
            path = Path.circle.cgPath
            
            proceedingLayer.frame = frame
            stopMarkLayer.frame = frame
            
            addSublayer(proceedingLayer)
            addSublayer(stopMarkLayer)
        }
        
        var proceeding: Float {
            get {
                return Float(proceedingLayer.strokeEnd)
            }
            set {
                proceedingLayer.strokeEnd = CGFloat(newValue)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private let downloadMeterLayer = DownloadMeterLayer(frame: CGRect(x: 0, y: 0, width: 74, height: 30))
    
    private let cloudImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "cloud"), highlightedImage: #imageLiteral(resourceName: "cloud_highlighted"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override var animations: Binder<(AppStoreButtonViewModel.State?, AppStoreButtonViewModel.State)> {
        return Binder<(AppStoreButtonViewModel.State?, AppStoreButtonViewModel.State)>(self, binding: { (target, stateSet) in
            let (current, next) = stateSet
            
            var isAnimationDisabled = current == nil
            
            switch next {
            case .get(let isHighlighted):
                // text
                target.text.isHidden = false
                target.text.text = "GET"
                target.text.textColor = isHighlighted ? Color.blueHighlighted : Color.blue
                
                // BaseLayer
                target.shapeLayer.path = Path.oval.cgPath
                target.shapeLayer.lineWidth = 0
                target.shapeLayer.fillColor = isHighlighted ? Color.grayHighlighted.cgColor : Color.gray.cgColor
                target.shapeLayer.strokeStart = 0
                target.shapeLayer.strokeEnd = 1.0
                
                // Download Meter
                target.downloadMeterLayer.isHidden = true
                
                // Cloud Image
                target.cloudImageView.isHidden = true
                
            case .loading:
                target.text.isHidden = true
                
                // BaseLayer
                target.shapeLayer.isHidden = false
                target.shapeLayer.removeAllAnimations()
                if let current = current, case .get(_) = current {
                    isAnimationDisabled = false
                } else {
                    isAnimationDisabled = true
                }
                
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    let animation = CABasicAnimation(keyPath: "transform.rotation")
                    animation.toValue = Float.pi / 2.0
                    animation.duration = 0.3
                    animation.repeatCount = MAXFLOAT
                    animation.isCumulative = true
                    target.shapeLayer.add(animation, forKey: "rotation")
                })
                
                if !isAnimationDisabled {
                    let animation = CABasicAnimation(keyPath: "path")
                    animation.fromValue = Path.oval.cgPath
                    animation.toValue = Path.circle.cgPath
                    target.shapeLayer.add(animation, forKey: nil)
                }
                
                target.shapeLayer.path = Path.circle.cgPath
                target.shapeLayer.fillColor = UIColor.white.cgColor
                target.shapeLayer.lineWidth = 2.0
                target.shapeLayer.strokeColor = Color.darkGray.cgColor
                target.shapeLayer.strokeStart = 0.1
                target.shapeLayer.strokeEnd = 0.9
                
                CATransaction.commit()
                
                target.cloudImageView.isHidden = true
                
            case .downloading(let proceeding):
                target.text.isHidden = true
                
                target.shapeLayer.isHidden = true
                
                // Download Meter
                target.downloadMeterLayer.isHidden = false
                if isAnimationDisabled {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    target.downloadMeterLayer.proceeding = proceeding
                    CATransaction.commit()
                } else {
                    target.downloadMeterLayer.proceeding = proceeding
                }
                
                target.cloudImageView.isHidden = true
                
            case .startDownload(let isHighlighted):
                target.text.isHidden = true
                
                target.shapeLayer.isHidden = true
                
                target.downloadMeterLayer.isHidden = true
                
                target.cloudImageView.isHidden = false
                target.cloudImageView.isHighlighted = isHighlighted
                
            case .open(let isHighlighted):
                target.text.isHidden = false
                target.text.text = "OPEN"
                target.text.textColor = isHighlighted ? Color.blueHighlighted : Color.blue
                
                // BaseLayer
                target.shapeLayer.removeAllAnimations()
                target.shapeLayer.isHidden = false
                target.shapeLayer.path = Path.oval.cgPath
                target.shapeLayer.lineWidth = 0
                target.shapeLayer.fillColor = isHighlighted ? Color.grayHighlighted.cgColor : Color.gray.cgColor
                target.shapeLayer.strokeStart = 0
                target.shapeLayer.strokeEnd = 1.0
                
                target.downloadMeterLayer.isHidden = true
                
                target.cloudImageView.isHidden = true
            }
        })
    }
    
    override init(initialState: AppStoreButtonViewModel.State) {
        super.init(initialState: initialState)
        
        layer.addSublayer(shapeLayer)
        layer.addSublayer(downloadMeterLayer)
        
        text.textColor = Color.blue
        text.textAlignment = .center
        text.font = UIFont.boldSystemFont(ofSize: 17.0)
        addSubview(text)
        
        addSubview(cloudImageView)
        cloudImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cloudImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 74, height: 30)
    }
}

extension AppStoreButton {
    struct Color {
        static let gray = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        static let blue = UIColor(red: 52.0/255.0, green: 120.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        static let darkGray = UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        static let grayHighlighted = UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 252.0/255.0, alpha: 1.0)
        static let blueHighlighted = UIColor(red: 204.0/255.0, green: 225.0/255.0, blue: 252.0/255.0, alpha: 1.0)
    }
    
    struct Path {
        static let oval: UIBezierPath = {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 15, y: 0))
            path.addLine(to: CGPoint(x: 59, y: 0))
            path.addArc(withCenter: CGPoint(x: 59, y: 15), radius: 15, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi/2, clockwise: true)
            path.addLine(to: CGPoint(x: 15, y: 30))
            path.addArc(withCenter: CGPoint(x: 15, y: 15), radius: 15, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi*3/2, clockwise: true)
            path.close()
            return path
        }()
        
        static let circle: UIBezierPath = {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 37, y: 3))
            path.addLine(to: CGPoint(x: 37, y: 3))
            path.addArc(withCenter: CGPoint(x: 37, y: 15), radius: 12, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi/2, clockwise: true)
            path.addLine(to: CGPoint(x: 37, y: 27))
            path.addArc(withCenter: CGPoint(x: 37, y: 15), radius: 12, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi*3/2, clockwise: true)
            path.close()
            return path
        }()
        
        static let stopMark: UIBezierPath = {
            let path = UIBezierPath(roundedRect: CGRect(x: 33, y: 11, width: 8, height: 8), cornerRadius: 1)
            return path
        }()
    }
}
