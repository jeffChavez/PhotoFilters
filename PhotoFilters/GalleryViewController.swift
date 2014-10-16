//
//  GalleryViewController.swift
//  PhotoFilters
//
//  Created by Jeff Chavez on 10/13/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//

import UIKit

protocol PassToVCDelegate {
    func didTapOnPicture (image: UIImage)
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collectionView : UICollectionView!
    
    var images = [UIImage]()
    
    var flowLayout : UICollectionViewFlowLayout!
    var pinchGesture = PinchGesture()
    
    var delegate : PassToVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        var image1 = UIImage(named: "edmPic1")
        var image2 = UIImage(named: "edmPic2")
        var image3 = UIImage(named: "edmPic3")
        var image4 = UIImage(named: "edmPic4")
        
        self.images.append(image1)
        self.images.append(image2)
        self.images.append(image3)
        self.images.append(image4)
        
        self.flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        
        self.pinchGesture.collectionView = self.collectionView
        self.pinchGesture.flowLayout = self.flowLayout
        
        var pinchRecognizer = UIPinchGestureRecognizer(target: pinchGesture, action: "handlePinch:")
        self.collectionView.addGestureRecognizer(pinchRecognizer)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.didTapOnPicture(self.images[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "GALLERY_CELL_HEADER", forIndexPath: indexPath) as Header
            header.sectionHeaderLabel.text = "Photos"
            return header
        } else {
            let footer = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "GALLERY_CELL_FOOTER", forIndexPath: indexPath) as Footer
            footer.sectionFooterLabel.text = String(self.images.count)
            return footer
        }
    }
}