//
//  RippleLayer.swift
//  Tindo
//
//  Created by Karthik Sakthivel on 04/12/17.
//  Copyright © 2017 Pyramidions. All rights reserved.
//
import UIKit

class RippleLayer: CAReplicatorLayer {
    fileprivate var rippleEffect: CALayer?
    private var animationGroup: CAAnimationGroup?
    var rippleRadius: CGFloat = 250.0
//    var rippleColor: UIColor = UIColor.red
    var startColor = UIColor() //UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1)
    var rippleRepeatCount: CGFloat = 10000.0
    var rippleWidth: CGFloat = 250
    
    override init() {
        super.init()
        if UserDefaults.standard.object(forKey: "myColor") != nil
        {
            //            mycolor = UserDefaults.standard.object(forKey: "mycolor")as! UIColor
            let colorData = UserDefaults.standard.object(forKey: "myColor") as! Data
            //            var color: UIColor? = nil
            startColor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as! UIColor
//           startColor =
        }
        else {
            startColor = UIColor.init(red: 107/255, green: 127/255, blue: 252/255, alpha: 1)
        }
        setupRippleEffect()
        
        repeatCount = Float(rippleRepeatCount)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        rippleEffect?.bounds = CGRect(x: 0, y: 0, width: rippleRadius*2, height: rippleRadius*2)
        rippleEffect?.cornerRadius = rippleRadius
        instanceCount = 2
        instanceDelay = 0.4
    }
    
    func setupRippleEffect() {
        rippleEffect = CALayer()
        rippleEffect?.borderWidth = CGFloat(rippleWidth)
        rippleEffect?.borderColor = startColor.cgColor
        rippleEffect?.opacity = 0
        
        addSublayer(rippleEffect!)
    }
    
    func startAnimation() {
        setupAnimationGroup()
        rippleEffect?.add(animationGroup!, forKey: "ripple")
    }
    
    func stopAnimation() {
        rippleEffect?.removeAnimation(forKey: "ripple")
    }
    
    func setupAnimationGroup() {
        let duration: CFTimeInterval = 4
        
        let group = CAAnimationGroup()
        group.duration = duration
        group.repeatCount = self.repeatCount
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = 0.1;
        scaleAnimation.toValue = 1.0;
        scaleAnimation.duration = duration
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = duration
        let fromAlpha = 1.0
        opacityAnimation.values = [(fromAlpha * 0.7),(fromAlpha * 0.5),(fromAlpha * 0.3), 0];
        opacityAnimation.keyTimes = [0.5,0.6,0.7, 0.8];
        
        group.animations = [scaleAnimation, opacityAnimation]
        
        animationGroup = group;
        animationGroup!.delegate = self;
    }
}

extension RippleLayer: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let count = rippleEffect?.animationKeys()?.count , count > 0 {
            rippleEffect?.removeAllAnimations()
        }
    }
}

