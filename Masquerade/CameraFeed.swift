//
//  CameraFeed.swift
//  Masquerade
//
//  Created by Labtanza on 10/7/20.
//

import SwiftUI
import AVFoundation

struct CameraFeed:UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    class CameraCoordinator: NSObject, UINavigationControllerDelegate {
        var parent: CameraFeed
        init(parent: CameraFeed) {
            self.parent = parent
        }

    }

    class CameraViewController:UIViewController {
        var delegate: CameraCoordinator?
        override public func loadView() {
            view = UIView()
            view.isUserInteractionEnabled = true
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            
            label.text = "This is a UIView. Tap anywhere to dismiss."
            label.textAlignment = .center
            
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.spacing = 50
            stackView.addArrangedSubview(label)
            //stackView.addArrangedSubview(button)
            
            view.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                //button.heightAnchor.constraint(equalToConstant: 50),
                stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            
        }
        
        override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.dismiss(animated: true, completion: nil)        }
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
