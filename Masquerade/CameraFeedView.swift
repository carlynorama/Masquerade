//
//  CameraFeedView.swift
//  Masquerade
//
//  Created by Labtanza on 10/7/20.
//

import SwiftUI

struct CameraFeedView: View {
    
    var body: some View {
        VStack {
            CameraFeed(codeTypes: [.face], completion: handleVideo)
        }
    }
}

func handleVideo(result: Result<String, CameraFeed.CameraError>) {
    switch result {
    case .success(let code):
        print(code)
    case .failure(let error):
        print("Scanning failed: \(error)")
    }
}

struct CameraFeedView_Previews: PreviewProvider {
    static var previews: some View {
        CameraFeedView()
    }
}
