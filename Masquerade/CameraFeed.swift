//
//  CameraFeed.swift
//  Masquerade
//
//  Created by Labtanza on 10/7/20.
//

import SwiftUI
import AVFoundation

struct CameraFeed:UIViewControllerRepresentable {
    //@Environment(\.presentationMode) var presentationMode
    public enum CameraError: Error {
        case badInput, badOutput
    }
    
    class CameraCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: CameraFeed
        var codeFound = false
        
        init(parent: CameraFeed) {
            self.parent = parent
        }
        
        public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                //print("found something?")
                if let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                    processMachineReadableObject(readableObject)
                }
                
                if let readableFaceObject = metadataObject as? AVMetadataFaceObject {
                    let bounds = readableFaceObject.bounds
                    found(code: "I found a face at \(bounds)")
                }

                

            }
        }
        
        func found(code: String) {
            print("found what I'm looking for")
            parent.completion(.success(code))
        }
        
        func didFail(reason: CameraError) {
            print("no dice")
            parent.completion(.failure(reason))
        }
        
        func processMachineReadableObject(_ readableObject:AVMetadataMachineReadableCodeObject) {
            guard let stringValue = readableObject.stringValue else { return }
            guard codeFound == false else { return }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
            // make sure we only trigger scans once per use
            codeFound = true
        }
        
        func processFaceObject(_ readableObject:AVMetadataFaceObject) {
            let bounds = readableObject.bounds
            found(code: "I found a face at \(bounds)")
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
            
            //Configure capture session
            captureSession = AVCaptureSession()
            
            
            // Define the capture device we want to use
            // Regular camera
            //guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                delegate?.didFail(reason: .badInput)
                //fatalError("camera requested not available")
                return
            }
            
            let videoInput: AVCaptureDeviceInput
            
            // Connect the camera to the capture session input
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
            
            // Create the video data output
            
            //let videoOutput = AVCaptureMetadataOutput()
            
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (captureSession.canAddOutput(metadataOutput)) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = delegate?.parent.codeTypes
            } else {
                delegate?.didFail(reason: .badOutput)
                return
            }
        }
        
        
        
        override public func viewWillLayoutSubviews() {
            //set the boundries
            previewLayer?.frame = view.layer.bounds
        }
        
        @objc func updateOrientation() {
            guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else { return }
            guard let connection = captureSession.connections.last, connection.isVideoOrientationSupported else { return }
            connection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
        }
        
        override public func viewDidAppear(_ animated: Bool) {
            // Configure the preview layer
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
    
    public let codeTypes: [AVMetadataObject.ObjectType]
    public var simulatedData = ""
    public var completion: (Result<String, CameraError>) -> Void

//    public init(codeTypes: [AVMetadataObject.ObjectType], simulatedData: String = "", completion: @escaping (Result<String, ScanError>) -> Void) {
//        self.codeTypes = codeTypes
//        self.simulatedData = simulatedData
//        self.completion = completion
//    }
    
    
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



//struct CameraFeed_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraFeed(codeTypes: [.qr], completion: <#(Result<String, CameraFeed.CameraError>) -> Void#>)
//    }
//}
