//
//  RewardEventChannel.swift
//  flutter_pangle_ad
//
//  Created by dmcb on 2021/4/12.
//

import UIKit
import Flutter

public class RewardEventChannel: NSObject,FlutterStreamHandler {
    
    var channel: FlutterEventChannel?
    public var event: FlutterEventSink?
    
    init(messenger: FlutterBinaryMessenger) {
        super.init()
        channel = FlutterEventChannel(name: "com.dcmb.rewardEvent", binaryMessenger: messenger)
        channel?.setStreamHandler(self)
    }
    
    
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    
}
