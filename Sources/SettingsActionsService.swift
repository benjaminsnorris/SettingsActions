/*
 |  _   ____   ____   _
 | ⎛ |‾|  ⚈ |-| ⚈  |‾| ⎞
 | ⎝ |  ‾‾‾‾| |‾‾‾‾  | ⎠
 |  ‾        ‾        ‾
 */

import Foundation
import MessageUI
import StoreKit

public struct SettingsActionService {
    
    // MARK: - Initializers
    
    public init() { }
    
    
    // MARK: - Public Functions
    
    public func sendFeedback(emailAddresses: [String], mailComposeDelegate: MFMailComposeViewControllerDelegate) {
        
    }
    
    public func shareApp(text: String, path: String, completion: ((activityType: String?) -> Void)? = nil) {

    }
    
    public func rateApp(iTunesItemIdentifier: Int, storeProductViewDelegate: SKStoreProductViewControllerDelegate) {
        
    }
    
    public func viewRelatedApp(iTunesItemIdentifier: Int, storeProductViewDelegate: SKStoreProductViewControllerDelegate) {
        
    }
    
}
