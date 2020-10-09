//
//  Face.swift
//  Masquerade
//
//  Created by Labtanza on 10/8/20.
//
import SwiftUI
import AVFoundation

struct Face {
    let id:Int
    let bounds:CGRect
    let hasRoll:Bool
    let roll:CGFloat
    let hasYaw:Bool
    let yaw:CGFloat
}

extension Face {
    init(_ faceObject:AVMetadataFaceObject) {
        id = faceObject.faceID
        bounds = faceObject.bounds
        hasRoll = faceObject.hasRollAngle
        roll = faceObject.rollAngle
        hasYaw = faceObject.hasYawAngle
        yaw = faceObject.yawAngle
    }
} 
