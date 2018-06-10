//
//  MainViewController.swift
//  MetalFilters
//
//  Created by xushuifeng on 2018/6/9.
//  Copyright © 2018 shuifeng.me. All rights reserved.
//

import UIKit
import Photos

class MainViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var albumView: UIView!
    
    fileprivate var selectedAsset: PHAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Metal Filters"
        // Do any additional setup after loading the view.
        
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    self.loadPhotos()
                }
                break
            case .notDetermined:
                break
            default:
                break
            }
        }
    }
    
    fileprivate func loadPhotos() {
        let option = PHFetchOptions()
        option.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false) ]
        let result = PHAsset.fetchAssets(with: option)
        if let firstAsset = result.firstObject {
            loadImageFor(firstAsset)
        }
        
        let albumController = AlbumPhotoViewController(dataSource: result)
        albumController.didSelectAssetHandler = { [weak self] selectedAsset in
            self?.loadImageFor(selectedAsset)
        }
        albumController.view.frame = albumView.bounds
        albumView.addSubview(albumController.view)
        addChildViewController(albumController)
        albumController.didMove(toParentViewController: self)
    }
    
    fileprivate func loadImageFor(_ asset: PHAsset) {
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil) { (image, _) in
            self.photoImageView.image = image
        }
        selectedAsset = asset
    }
    
    fileprivate func loadImageForEditing(_ asset: PHAsset) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        asset.requestContentEditingInput(with: options) { (input, info) in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let editorController = mainStoryBoard.instantiateViewController(withIdentifier: "PhotoEditorViewController") as? PhotoEditorViewController else {
            return
        }
        editorController.originAsset = selectedAsset
        navigationController?.pushViewController(editorController, animated: false)
    }
    
}