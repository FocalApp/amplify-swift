//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

public struct KeychainStoreGlobalSettings {
    // shared keychain access group id
    public static var globalAccessGroup: String?
    
    // used as kSecAttrService
    public static var bundleIdentifier: String?
}

struct KeychainStoreAttributes {
    var itemClass: String = KeychainStore.Constants.ClassGenericPassword
    var service: String
    var accessGroup: String?
}

extension KeychainStoreAttributes {

    func defaultGetQuery() -> [String: Any] {
        var query: [String: Any] = [
            KeychainStore.Constants.Class: itemClass,
            KeychainStore.Constants.AttributeService: service,
            KeychainStore.Constants.UseDataProtectionKeyChain: kCFBooleanTrue
        ]
        
        if let globalAccessGroup = accessGroup {
            query[KeychainStore.Constants.AttributeAccessGroup] = globalAccessGroup
        }
        
        return query
    }

    func defaultSetQuery() -> [String: Any] {
        var query: [String: Any] = defaultGetQuery()
        query[KeychainStore.Constants.AttributeAccessible] = KeychainStore.Constants.AttributeAccessibleAfterFirstUnlockThisDeviceOnly
        query[KeychainStore.Constants.UseDataProtectionKeyChain] = kCFBooleanTrue
        return query
    }
}
