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
    private static let isStorageEnableUDID = "isStorageEnableUDID"
    /** directoryPath's UserDefault ID */
    private static let directoryPathUDID = "directoryPathUDID"
    /** excludeFolders's UserDefault ID */
    private static let excludeFoldersUDID = "excludeFoldersUDID"
    /** excludeFileNames's UserDefault ID */
    private static let excludeFileNamesUDID = "iexcludeFileNamesUDID"
    
    // MARK:
    
    private static var _sharedSearchPreferences: SearchPreferences?
    
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
                let userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.setObject(directoryPath, forKey: SearchPreferences.directoryPathUDID)
                userDefault.synchronize()
            }
        }
    }
    /** 想要排除在搜尋之外的資料夾 */
    var excludeFolders: [String]? {
        didSet {
            if isStorageEnable {
                let userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.setObject(excludeFolders, forKey: SearchPreferences.excludeFoldersUDID)
                userDefault.synchronize()
            }
        }
    }
    /** 想要排除在搜尋之外的檔案名稱 */
    var excludeFileNames: [String]? {
        didSet {
            if isStorageEnable {
                let userDefault = NSUserDefaults.standardUserDefaults()
                userDefault.setObject(excludeFileNames, forKey: SearchPreferences.excludeFileNamesUDID)
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
    
    private init () {
        let userDefault = NSUserDefaults.standardUserDefaults()
        isStorageEnable = userDefault.boolForKey(SearchPreferences.isStorageEnableUDID)
        loadLocalPreferencesData()
    }
    
    
    /** 將當前 SearchPreferences 資料儲存到本地端的 UserDefault。 */
    private func saveCurrentData() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(isStorageEnable, forKey: SearchPreferences.isStorageEnableUDID)
        userDefault.setObject(directoryPath, forKey: SearchPreferences.directoryPathUDID)
        userDefault.setObject(excludeFolders, forKey: SearchPreferences.excludeFoldersUDID)
        userDefault.setObject(excludeFileNames, forKey: SearchPreferences.excludeFileNamesUDID)
        userDefault.synchronize()
    }
    
    /** 將本地的 UserDefault 有關 SearchPreferences 的資料清空 */
    private func cleanAllData() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(false, forKey: SearchPreferences.isStorageEnableUDID)
        userDefault.setObject(nil, forKey: SearchPreferences.directoryPathUDID)
        userDefault.setObject(nil, forKey: SearchPreferences.excludeFoldersUDID)
        userDefault.setObject(nil, forKey: SearchPreferences.excludeFileNamesUDID)
        userDefault.synchronize()
    }
    
    /** 從本地端的 UserDefault 拿取資料 */
    private func loadLocalPreferencesData() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        directoryPath = userDefault.stringForKey(SearchPreferences.directoryPathUDID)
        excludeFolders = userDefault.stringArrayForKey(SearchPreferences.excludeFoldersUDID)
        excludeFileNames = userDefault.stringArrayForKey(SearchPreferences.excludeFileNamesUDID)
    }
    
}

