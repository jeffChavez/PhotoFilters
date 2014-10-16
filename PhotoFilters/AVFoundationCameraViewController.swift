//
//  AVFoundationCameraViewController.swift
//  PhotoFilters
//
//  Created by Jeff Chavez on 10/16/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import CoreVideo
import ImageIO
import QuartzCore

class AVFoundationCameraViewController: UIViewController {
    
    @IBOutlet weak var capturePreviewImageView: UIImageView!
    
    var stillImageOutput = AVCaptureStillImageOutput()
    var delegate : PassToVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRectMake(0, 64, self.view.frame.size.width, CGFloat(self.view.frame.size.height * 0.6))
        self.view.layer.addSublayer(previewLayer)
        
        var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput!
        if input == nil {
            println("bad!")
        }
        captureSession.addInput(input)
        var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        self.stillImageOutput.outputSettings = outputSettings
        captureSession.addOutput(self.stillImageOutput)
        captureSession.startRunning()
        
        createButtons()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func capturePressed(sender: AnyObject) {
        
        var videoConnection : AVCaptureConnection?
        for connection in self.stillImageOutput.connections {
            if let cameraConnection = connection as? AVCaptureConnection {
                for port in cameraConnection.inputPorts {
                    if let videoPort = port as? AVCaptureInputPort {
                        if videoPort.mediaType == AVMediaTypeVideo {
                            videoConnection = cameraConnection
                            break;
                        }
                    }
                }
            }
            if videoConnection != nil {
                break;
            }
        }
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(buffer : CMSampleBuffer!, error : NSError!) -> Void in
            var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
            var image = UIImage(data: data)
            self.capturePreviewImageView.image = image
            println(image.size)
        })
    }
    
    func createButtons () {
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneTakingPicture")
        self.navigationItem.rightBarButtonItem = doneButton
        
        var cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Done, target: self, action: "cancelTakingPicture")
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func doneTakingPicture () {
        delegate?.didTapOnPicture(self.capturePreviewImageView.image!)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelTakingPicture () {
        dismissViewControllerAnimated(true, completion: nil)
    }
}