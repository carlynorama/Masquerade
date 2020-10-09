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
                    Rectangle()
                        .stroke()
                        .foregroundColor(.orange)
                        .frame(width: 100, height: 100, alignment: .topLeading)
                        .position(x: geometry.size.width * foundFace!.origin.x, y: geometry.size.height * foundFace!.origin.y)
                        
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
            //TODO: Add a timer so if not updated in time foundFace = nil / opcity of rectangle?
        case .failure(let error):
            print("Scanning failed: \(error)")
            foundFace = nil
        }
    }

}

struct FoundObject: Shape {
    func reMapBoundries(frameRect:CGRect, boundsRect:CGRect) -> CGRect {
        //Y bounded to width? Really?
        let newY = (frameRect.width * boundsRect.origin.x) + (1.0-frameRect.origin.x)
        //X bounded to height? Really?
        let newX = (frameRect.height * boundsRect.origin.y) + (1.0-frameRect.origin.y)
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
