//
//  PhotoAlbum.swift
//  PhotoBlitz
//
//  Created by Sean Murphy on 9/10/16.
//  Copyright © 2016 Sean Murphy. All rights reserved.
//

import Photos

class PhotoAlbum {

	static let albumName = "Flashpod"
	static let sharedInstance = PhotoAlbum()

	var assetCollection: PHAssetCollection!

	init() {

		func fetchAssetCollectionForAlbum() -> PHAssetCollection! {

			let fetchOptions = PHFetchOptions()
			fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoAlbum.albumName)
			let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)

			if let _: AnyObject = collection.firstObject {
				return collection.firstObject as! PHAssetCollection
			}

			return nil
		}

		if let assetCollection = fetchAssetCollectionForAlbum() {
			self.assetCollection = assetCollection
			return
		}

		PHPhotoLibrary.sharedPhotoLibrary().performChanges({
			PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(PhotoAlbum.albumName)
		}) { success, _ in
			if success {
				self.assetCollection = fetchAssetCollectionForAlbum()
			}
		}
	}

	func saveImage(image: UIImage) {

		if assetCollection == nil {
			return   // If there was an error upstream, skip the save.
		}

		PHPhotoLibrary.sharedPhotoLibrary().performChanges({
			let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
			let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
			let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
			albumChangeRequest!.addAssets([assetPlaceHolder!])
			}, completionHandler: nil)
	}
	
}