//
//  ViewController.swift
//  PhotoBlitz
//
//  Created by Sean Murphy on 9/10/16.
//  Copyright © 2016 Sean Murphy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import AVFoundation

class ViewController: UIViewController {

	let storageRef = FIRStorage.storage().referenceForURL("gs://photoblitz-c9f3d.appspot.com")
	let databaseRef = FIRDatabase.database().reference()


	let userID = "PbfzlhM9fya6OXzy9EyiEyCYoJG2"

	let captureSession = AVCaptureSession()
	let stillImageOutput = AVCaptureStillImageOutput()
	var error: NSError?
	override func viewDidLoad() {
		super.viewDidLoad()
		print(databaseRef)
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
//				UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
				self.saveToFirebase(imageData)
			}
		}
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	let albumID = NSUUID().UUIDString

	func saveToFirebase(nsdata: NSData){
		let data: NSData = nsdata
		let imageID = NSUUID().UUIDString
		let metadata = FIRStorageMetadata()
		metadata.contentType = "image/jpeg"
		let image = storageRef.child("images/\(albumID)/\(imageID)")
		databaseRef.child("user").setValue("userID")
		databaseRef.child("user/album").childByAutoId()
			let uploadTask = image.putData(data, metadata: metadata) { metadata, error in
				if (error != nil) {
					print(error)
				} else {
					let downloadURL = metadata!.downloadURL
					print(downloadURL)
				}
			}

	}

}
