//
//  ViewController.swift
//  PhotoBlitz
//
//  Created by Sean Murphy on 9/10/16.
//  Copyright © 2016 Sean Murphy. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class ViewController: UIViewController {

	let storageRef = FIRStorage.storage().referenceForURL("gs://photoblitz-c9f3d.appspot.com")

		let captureSession = AVCaptureSession()
		let stillImageOutput = AVCaptureStillImageOutput()
		var error: NSError?
		override func viewDidLoad() {
			super.viewDidLoad()
			let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Back }
			if let captureDevice = devices.first as? AVCaptureDevice  {

				do {
					let input = try AVCaptureDeviceInput(device: captureDevice)
					captureSession.addInput(input)
				} catch _ {
					print("error: \(error?.localizedDescription)")
				}
				captureSession.sessionPreset = AVCaptureSessionPresetPhoto
				captureSession.startRunning()
				stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
				if captureSession.canAddOutput(stillImageOutput) {
					captureSession.addOutput(stillImageOutput)
				}
				if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
					previewLayer.bounds = view.bounds
					previewLayer.position = CGPointMake(view.bounds.midX, view.bounds.midY)
					previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
					let cameraPreview = UIView(frame: CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.size.height))
					cameraPreview.layer.addSublayer(previewLayer)
					cameraPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(ViewController.saveToCamera(_:))))
					view.addSubview(cameraPreview)
				}
			}
		}
		func saveToCamera(sender: UITapGestureRecognizer) {
			if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
				stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
					(imageDataSampleBuffer, error) -> Void in
					let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
					UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
					self.saveToFirebase(imageData)
				}
			}
		}
		override func didReceiveMemoryWarning() {
			super.didReceiveMemoryWarning()
		}

	func saveToFirebase(nsdata: NSData){
		let data: NSData = nsdata
		let imagesRef = storageRef.child("images")
		let image = storageRef.child("images/image")

		let uploadTask = image.putData(data, metadata: nil) { metadata, error in
			if (error != nil) {
				print(error)
			} else {
    let downloadURL = metadata!.downloadURL
				print(metadata)
			}
		}
	}
}
