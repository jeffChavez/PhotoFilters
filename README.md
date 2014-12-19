PhotoFilters
============
Week 2 Assignment
Add your favorite "Instagram" filters to any photo<br>

Selecting a photo from a photo gallery (collection view)
![Imgur](http://i.imgur.com/L1IYqtZ.gif)

Selecting a filter by scrolling through thumbnail images representing a specific filter
![Imgur](http://i.imgur.com/4hUO1ao.gif)

###Features
- CoreData for persisting the different filter name strings
- CoreImage for image filters, using custom input keys for specific filters
- Photos for saving to photo album
- `UICollectionView`
- `UICollectionViewFlowLayout` for using a pinch gesture to resize collection views
- AVFoundation for taking pictures
- Working with `NSLayoutConstraint` to move objects instead of `view.center`
- Delegation, for passing the image selected back in `GalleryViewController` back to `ViewController`
- Animations
- Programatically created User interfaces (the three colored boxes when selecting a filter)

###Assignment
Monday
- Add an action sheet to the home view controller that gives the user options of choosing a photo from the gallery or the camera.
- Create the gallery view controller that displays the photos provided in a collection view.
- Create a custom protocol for when a user selects a photo from the gallery. The protocol method should pass back the UIImage they select and then the home view controller should display the photo.
- Implement UIImagePickerController for the camera and allow the user to take a picture with the camera and then have the photo show up in the image view on the home view controller.

Tuesday
- Implement core data and store at least 10 filters in your data store.
- Create a collection view that displays thumbnails of the selected photo with each filter applied to it.
- When a user selects a filtered thumbnail it should apply the filter to the primary image.

Wednesday
- Incorporate the photos framework into your app. Create a separate view control that is used just for displaying photos fetched from the framework.
- Create a way to get the selected photo from the photos framework back to the main view controller. Remember each photo is represented by a PHAsset. And you will want to request a new photo since the size will be much bigger for the main image view.
- Get the nodeJS script I pushed to the class repo up and running on your computer, and open access your web server via a browser.

Thursday
- Implement the pinch to zoom recognizer for zooming in and out of your gallery and/or photos frame work view controller. Make sure there is some sort of restriction on it, so i can't zoom in and out forever.
- Plug in the AVFoundationSwift view controller provided in the class repo. Run it on your device and see how it works.
- Implement a Linked List with Generics, and implement adding and removing nodes on the linked list.

Friendship Friday
Pair programming rules:
- You must be working in a pair of 2 at all times. The best pairs have similar experience levels. Choose a new partner each week!
- One person will be typing (driving), but the other person needs to actively contribute. Each line of code you guys write should be discussed and decided upon. Keep an open mind, and if you guys disagree on something, try one way first and see if it works, if it doesn't try the other way.
- Don't physically harm your partner.
- Switch roles every half hour.
- Remember to high-five when you guys do something awesome. See http://en.wikipedia.org/wiki/High_five (Links to an external site.) for more info on this social ritual.
- The friendship friday challenges can be submitted jointly, if the work you did is on a different person's project, please note that in your homework submission. If the feature(s) you guys built is so awesome you just have to have it in your own project, copy it over.

Challenges:
- Use the social framework to post the filtered photo to a social network.
- Use the Photos Framework to save the filtered photo to the users Photos collection.
- Add a filter not mentioned in the gitter.im chat room that needs extra input keys.
