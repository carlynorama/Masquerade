//
//  CameraFeedView.swift
//  Masquerade
//
//  Created by Labtanza on 10/7/20.
//

import SwiftUI

struct CameraFeedView: View {
    @State private var image: Image?
    @State private var showingUIView = false
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFit()
            
            Button("Pull Up UIView") {
                self.showingUIView = true
            }
        }
        .sheet(isPresented: $showingUIView) {
            CameraFeed()
        }
    }
}

struct CameraFeedView_Previews: PreviewProvider {
    static var previews: some View {
        CameraFeedView()
    }
}
