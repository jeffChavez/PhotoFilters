//
//  PhotoFrameworkViewController.swift
//  PhotoFilters
//
//  Created by Jeff Chavez on 10/15/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//

import UIKit
import Photos

class PhotoFrameworkViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collectionView : UICollectionView!
    
    var assetFetchResults: PHFetchResult!
    var assetCollection: PHAssetCollection!
    var imageManager: PHCachingImageManager!
    var assetCellSize: CGSize!
    var vcCellSize: CGSize!
    
    var images = [UIImage]()
    
    var delegate : PassToVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get image image, asset fetch results
        self.imageManager = PHCachingImageManager()
        
        // Pass nil, fetch all assets
        self.assetFetchResults = PHAsset.fetchAssetsWithOptions(nil)
        
        // Determine device scale, adjust asset cell size
        var scale = UIScreen.mainScreen().scale
        var flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        
        var cellSize = flowLayout.itemSize
        self.assetCellSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetFetchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_FRAMEWORK_CELL", forIndexPath: indexPath) as PhotoFrameworkCell
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            cell.imageView.image = image
            }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        self.imageManager.requestImageForAsset(asset, targetSize: self.vcCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            self.delegate?.didTapOnPicture(image)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}