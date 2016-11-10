//
//  SearchPreferences.swift
//  CheckDuplicateFileName
//
//  Created by NixonShih on 2016/10/20.
//  Copyright © 2016年 Nixon. All rights reserved.
//

import Foundation

/**
 **SettingPreferences**
 
 
 這個 Class 負責儲存搜尋的設定
 */
class SearchPreferences {
    
    // MARK: - UserDefault IDs
    
    /** isStorageEnable's UserDefault ID */
    fileprivate static let isStorageEnableUDID = "isStorageEnableUDID"
    /** directoryPath's UserDefault ID */
    fileprivate static let directoryPathUDID = "directoryPathUDID"
    /** excludeFolders's UserDefault ID */
    fileprivate static let excludeFoldersUDID = "excludeFoldersUDID"
    /** excludeFileNames's UserDefault ID */
    fileprivate static let excludeFileNamesUDID = "iexcludeFileNamesUDID"
    
    // MARK:
    
    fileprivate static var _sharedSearchPreferences: SearchPreferences?
    
    /** 是否要儲存設定 */
    var isStorageEnable: Bool {
        didSet {
            if isStorageEnable {
                saveCurrentData()
            }else{
                cleanAllData()
            }
        }
    }
    /** 要搜尋的路徑 */
    var directoryPath: String? {
        didSet {
            if isStorageEnable {
                let userDefault = UserDefaults.standard
                userDefault.set(directoryPath, forKey: SearchPreferences.directoryPathUDID)
                userDefault.synchronize()
            }
        }
    }
    /** 想要排除在搜尋之外的資料夾 */
    var excludeFolders: [String]? {
        didSet {
            if isStorageEnable {
                let userDefault = UserDefaults.standard
                userDefault.set(excludeFolders, forKey: SearchPreferences.excludeFoldersUDID)
                userDefault.synchronize()
            }
        }
    }
    /** 想要排除在搜尋之外的檔案名稱 */
    var excludeFileNames: [String]? {
        didSet {
            if isStorageEnable {
                let userDefault = UserDefaults.standard
                userDefault.set(excludeFileNames, forKey: SearchPreferences.excludeFileNamesUDID)
                userDefault.synchronize()
            }
        }
    }
    
    // MARK: - Public Methods
    
    /**
     透過這個方法拿到 SearchPreferences's singleton instance
     - returns: SearchPreferences's singleton instance
     */
    static func sharedInstance() -> SearchPreferences {
        
        if let _sharedInstance = _sharedSearchPreferences {
            return _sharedInstance
        }
        
        let _sharedInstance = SearchPreferences()
        _sharedSearchPreferences = _sharedInstance
        
        return _sharedInstance
    }
    
    // MARK: - Private Methods
    
    fileprivate init () {
        let userDefault = UserDefaults.standard
        isStorageEnable = userDefault.bool(forKey: SearchPreferences.isStorageEnableUDID)
        loadLocalPreferencesData()
    }
    
    
    /** 將當前 SearchPreferences 資料儲存到本地端的 UserDefault。 */
    fileprivate func saveCurrentData() {
        let userDefault = UserDefaults.standard
        userDefault.set(isStorageEnable, forKey: SearchPreferences.isStorageEnableUDID)
        userDefault.set(directoryPath, forKey: SearchPreferences.directoryPathUDID)
        userDefault.set(excludeFolders, forKey: SearchPreferences.excludeFoldersUDID)
        userDefault.set(excludeFileNames, forKey: SearchPreferences.excludeFileNamesUDID)
        userDefault.synchronize()
    }
    
    /** 將本地的 UserDefault 有關 SearchPreferences 的資料清空 */
    fileprivate func cleanAllData() {
        let userDefault = UserDefaults.standard
        userDefault.set(false, forKey: SearchPreferences.isStorageEnableUDID)
        userDefault.set(nil, forKey: SearchPreferences.directoryPathUDID)
        userDefault.set(nil, forKey: SearchPreferences.excludeFoldersUDID)
        userDefault.set(nil, forKey: SearchPreferences.excludeFileNamesUDID)
        userDefault.synchronize()
    }
    
    /** 從本地端的 UserDefault 拿取資料 */
    fileprivate func loadLocalPreferencesData() {
        let userDefault = UserDefaults.standard
        directoryPath = userDefault.string(forKey: SearchPreferences.directoryPathUDID)
        excludeFolders = userDefault.stringArray(forKey: SearchPreferences.excludeFoldersUDID)
        excludeFileNames = userDefault.stringArray(forKey: SearchPreferences.excludeFileNamesUDID)
    }
    
}

