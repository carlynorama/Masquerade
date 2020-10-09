//
//  CameraFeedView.swift
//  Masquerade
//
//  Created by Labtanza on 10/7/20.
//

import SwiftUI

struct CameraFeedView: View {
    @State var foundFace:CGRect?
    @State var geometryRect:CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    //var testRect:CGRect = CGRect(x: 0.44112000039964916, y: 0.1979580322805941, width: 0.3337599992007017, height: 0.5941303606941507)
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                CameraFeed(codeTypes: [.face], completion: handleCameraReturn)
                if (foundFace != nil) {
                    FoundObject(frameRect: geometryRect, boundsRect: foundFace!)
                        .stroke()
                        .foregroundColor(.blue)
                }
            }
            .onAppear(perform: {
                let frame = geometry.frame(in: .global)
                geometryRect = CGRect(origin: CGPoint(x: frame.minX, y: frame.minY), size: geometry.size)
            })
        })
        
    }
    
    func handleCameraReturn(result: Result<CGRect, CameraFeed.CameraError>) {
        switch result {
        case .success(let bounds):
            print(bounds)
            foundFace = bounds
        case .failure(let error):
            print("Scanning failed: \(error)")
        }
    }

}

struct FoundObject: Shape {
    func reMapBoundries(frameRect:CGRect, boundsRect:CGRect) -> CGRect {
        let newX = (frameRect.width * boundsRect.origin.x) + frameRect.origin.x
        let newY = (frameRect.height * boundsRect.origin.y) + frameRect.origin.y
        let newWidth = (frameRect.width * boundsRect.width)
        let newHeight = (frameRect.height * boundsRect.height)
        let newRect = CGRect(origin: CGPoint(x: newX, y: newY), size: CGSize(width: newWidth, height: newHeight))
        return newRect
    }
    
    let frameRect:CGRect
    let boundsRect:CGRect
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(reMapBoundries(frameRect: frameRect, boundsRect: boundsRect))
        return path
    }
}


struct CameraFeedView_Previews: PreviewProvider {
    static var previews: some View {
        CameraFeedView()
    }
}
