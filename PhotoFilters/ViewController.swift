//
//  ViewController.swift
//  PhotoFilters
//
//  Created by Jeff Chavez on 10/13/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GalleryDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    @IBOutlet var photoImageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as GalleryViewController
        destinationVC.delegate = self
    }

    @IBAction func photoButtonPressed (sender: AnyObject) {
        let alertControlller = UIAlertController(title: nil, message: "Choose an option", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let galleryAction = UIAlertAction(title: "gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
        }
        let photoAlbumAction = UIAlertAction(title: "Choose Existing", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            self.presentViewController(imagePicker, animated: true, completion:nil)
        }
        let cameraAction = UIAlertAction(title: "Take a Photo", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            } else {
                let alertView = UIAlertView()
                alertView.title = "Error"
                alertView.message = "You do not have a camera available"
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
        let deleteAction = UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            self.photoImageView.image = nil
        }
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertControlller.addAction(galleryAction)
        alertControlller.addAction(photoAlbumAction)
        alertControlller.addAction(cameraAction)
        if self.photoImageView.image != nil {
            alertControlller.addAction(deleteAction)
        }
        alertControlller.addAction(cancelAction)
        
        //when the view controller is presented a strong reference is created.
        self.presentViewController(alertControlller, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.photoImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapOnPicture(image: UIImage) {
        self.photoImageView.image = image
    }
}