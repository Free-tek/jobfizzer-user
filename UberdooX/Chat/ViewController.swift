//
//  ViewController.swift
//  PageCollectionView
//
//  Created by Pyramidions on 03/01/19.
//  Copyright © 2019 Pyramidions. All rights reserved.
//

import UIKit
import CenteredCollectionView

class ViewController: UIViewController,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    
    let cellPercentWidth: CGFloat = 0.8
    var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!


    @IBOutlet weak var collectView: UICollectionView!
    var isfirstTimeTransform:Bool = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centeredCollectionViewFlowLayout = (collectView.collectionViewLayout as! CenteredCollectionViewFlowLayout)

        collectView.decelerationRate = UIScrollViewDecelerationRateFast

        collectView.delegate = self
        collectView.dataSource = self
        
        centeredCollectionViewFlowLayout.itemSize = CGSize(
            width: view.bounds.width * cellPercentWidth,
            height: 210
        )
        
        // Configure the optional inter item spacing (OPTIONAL)
        centeredCollectionViewFlowLayout.minimumLineSpacing = 20
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannersCollectionViewCell", for: indexPath) as! BannersCollectionViewCell

        cell.label.text = "Cell #\(indexPath.row)"

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
            return CGSize(width: view.bounds.width * cellPercentWidth, height: 210)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
            return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        
            return 20
    }
}

