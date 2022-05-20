//
//  ExFlutterMethodCall.swift
//  flutter_pangle_ad
//
//  Created by dmcb on 2022/5/20.
//
import Flutter
import Foundation

extension FlutterMethodCall {
    
    func getValue<T>(key: String) -> T?{
        
        guard let result = (arguments as? Dictionary<String, Any>)?[key] as? T else {
            return nil
        }
        return result
        
    }
    
    func getNumber(key: String) -> NSNumber? {
        guard let result = (arguments as? Dictionary<String, Any>)?[key] as? NSNumber else {
            return nil
        }
        return result
    }

    func getString(key: String) -> String? {
        guard let result = (arguments as? Dictionary<String, Any>)?[key] as? String else {
            return nil
        }
        return result
    }

    func getBool(key: String) -> Bool? {
        guard let result = (arguments as? Dictionary<String, Any>)?[key] as? Bool else {
            return nil
        }
        return result
    }

    func getInt(key: String) -> Int? {
        guard let result = (arguments as? Dictionary<String, Any>)?[key] as? Int else {
            return nil
        }
        return result
    }

    func getDouble(key: String) -> Double? {
        guard let result = (arguments as? Dictionary<String, Any>)?[key] as? Double else {
            return nil
        }
        return result
    }

    func getDict(key: String) -> Dictionary<String, Any>? {
        guard let result = (arguments as? Dictionary<String, Any>)?[key] as? Dictionary<String, Any> else {
            return nil
        }
        return result
    }
}
