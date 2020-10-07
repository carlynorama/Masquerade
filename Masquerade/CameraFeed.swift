//
//  CameraFeed.swift
//  Masquerade
//
//  Created by Labtanza on 10/7/20.
//

import SwiftUI
import AVFoundation

struct CameraFeed:UIViewControllerRepresentable {
    
    class CameraCoordinator: NSObject, UINavigationControllerDelegate {
        var parent: CameraFeed
        init(parent: CameraFeed) {
            self.parent = parent
        }
    }

    class CameraViewController:UIViewController {
        var delegate: CameraCoordinator?
       // UIImagePickerController()
    }
    
    public func makeCoordinator() -> CameraCoordinator {
        //return CameraCoordinator(parent: self)
        CameraCoordinator(parent: self)
    }
    
    public func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    public func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {

    }
    

    

}



struct CameraFeed_Previews: PreviewProvider {
    static var previews: some View {
        CameraFeed()
    }
}
