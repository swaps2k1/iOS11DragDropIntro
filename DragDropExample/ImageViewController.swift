//
//  ImageViewController.swift
//  DragDropExample
//
//  Created by Salunke, Swapnil Uday (US - Mumbai) on 6/14/17.
//  Copyright © 2017 Deloitte Digital. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController ,UIDropInteractionDelegate, UIDragInteractionDelegate {
    
    // MARK: - Controller Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addInteraction(UIDropInteraction(delegate: self))
        view.addInteraction(UIDragInteraction(delegate: self))
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Drag interaction methods
    // Perfrom Drag
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        let touchedPoint = session.location(in: self.view)
        if let touchedImageView = self.view.hitTest(touchedPoint, with: nil) as? UIImageView{
            
            let touchedImage = touchedImageView.image
            let itemProvider = NSItemProvider(object: touchedImage!)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = touchedImageView
            return [dragItem]
        }
        return[]
    }
    //Create custom drag preview
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        return UITargetedDragPreview(view: item.localObject as! UIView)
    }
    //Animate and Remove from superview to mimic a move
    func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {
        
        session.items.forEach { (dragItem) in
            if let touchedImageView = dragItem.localObject as? UIView
            {
                touchedImageView.removeFromSuperview()
            }
        }
    }
    //On cancel, reposition object back to its original position.
    func dragInteraction(_ interaction: UIDragInteraction, item: UIDragItem, willAnimateCancelWith animator: UIDragAnimating) {
        self.view.addSubview(item.localObject as! UIView)
    }
    
    // MARK: - Drop interaction methods
    //Perform Drop
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for dragItem in session.items{
            dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (obj, err) in
                if let err = err{
                    print ("Failed to load drag item:",err)
                    return
                }
                guard let draggedImage = obj as? UIImage else{
                    return
                }
                
                DispatchQueue.main.async {
                    let imageView =  UIImageView(image: draggedImage)
                    imageView.isUserInteractionEnabled = true
                    self.view.addSubview(imageView)
                    imageView.frame = CGRect(x: 0, y: 0, width: draggedImage.size.width, height: draggedImage.size.height)
                    
                    let centerpoint = session.location(in: self.view)
                    imageView.center = centerpoint
                }
                
            })
        }
    }
    
    //Create contract for Drop
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    //Create drop Proposal
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
}
