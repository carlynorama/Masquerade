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
    
    #if targetEnvironment(simulator)
    class CameraViewController:UIViewController {
        var delegate: CameraCoordinator?
        override public func loadView() {
            view = UIView()
            view.isUserInteractionEnabled = true
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            
            label.text = "This is supposed to be a camera feed, but you are on the simulator."
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
            //self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    #else
    public class CameraViewController: UIViewController {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        var delegate: CameraCoordinator?
        
        override public func viewDidLoad() {
            super.viewDidLoad()
            
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(updateOrientation),
                                                   name: Notification.Name("UIDeviceOrientationDidChangeNotification"),
                                                   object: nil)
            
            view.backgroundColor = UIColor.black
            captureSession = AVCaptureSession()
            
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput
            
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }
            
            if (captureSession.canAddInput(videoInput)) {
                captureSession.addInput(videoInput)
            } else {
                delegate?.didFail(reason: .badInput)
                return
            }
            
            //            let metadataOutput = AVCaptureMetadataOutput()
            //
            //            if (captureSession.canAddOutput(metadataOutput)) {
            //                captureSession.addOutput(metadataOutput)
            //
            //                metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            //                metadataOutput.metadataObjectTypes = delegate?.parent.codeTypes
            //            } else {
            //                delegate?.didFail(reason: .badOutput)
            //                return
            //            }
        }
        
        override public func viewWillLayoutSubviews() {
            previewLayer?.frame = view.layer.bounds
        }
        
        @objc func updateOrientation() {
            guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else { return }
            guard let connection = captureSession.connections.last, connection.isVideoOrientationSupported else { return }
            connection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
        }
        
        override public func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            updateOrientation()
            captureSession.startRunning()
        }
        
        override public func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if (captureSession?.isRunning == false) {
                captureSession.startRunning()
            }
        }
        
        override public func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            if (captureSession?.isRunning == true) {
                captureSession.stopRunning()
            }
            
            NotificationCenter.default.removeObserver(self)
        }
        
        override public var prefersStatusBarHidden: Bool {
            return true
        }
        
        override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .all
        }
    }
    #endif
    
    
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
