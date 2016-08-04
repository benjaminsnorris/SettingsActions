/*
 |  _   ____   ____   _
 | ⎛ |‾|  ⚈ |-| ⚈  |‾| ⎞
 | ⎝ |  ‾‾‾‾| |‾‾‾‾  | ⎠
 |  ‾        ‾        ‾
 */

import Foundation
import MessageUI
import StoreKit
import DeviceInfo

public struct SettingsActionService {
    
    // MARK: - Internal properties
    
    var deviceInfoService = DeviceInfoService()
    var versionNumberService = VersionNumberService()
    
    
    // MARK: - Constants
    
    private let ratingLinkPathPrefix = "itms-apps://itunes.apple.com/app/id"
    
    
    // MARK: - Initializers
    
    public init() { }
    
    
    // MARK: - Public Functions
    
    public func sendFeedback(fromViewController viewController: UIViewController, emailAddresses: [String], mailComposeDelegate: MFMailComposeViewControllerDelegate) {
        let feedback = MFMailComposeViewController()
        feedback.mailComposeDelegate = mailComposeDelegate
        feedback.setToRecipients(emailAddresses)
        feedback.setSubject("Some thoughts on \(deviceInfoService.appName)")
        let supportInfo = "iOS \(deviceInfoService.osVersion) on \(deviceInfoService.deviceName) \nLocale: \(deviceInfoService.locale) (\(deviceInfoService.language)) \n\(versionNumberService.appNameWithVersion))"
        let messageText = "Here are my thoughts:\n\n\n\n\n\n--------------------------------\nDeveloper Support Information\n\n\(supportInfo)\n--------------------------------\n"
        feedback.setMessageBody(messageText, isHTML: false)
        viewController.presentViewController(feedback, animated: true, completion: nil)
    }
    
    public func shareApp(fromViewController viewController: UIViewController, message: String? = nil, appStoreAppPath: String, completion: ((activityType: String?) -> Void)? = nil) {
        let message = message ?? "Check out \(deviceInfoService.appName), an app I've really been enjoying."
        var activityItems: [AnyObject] = [message]
        if let appLink = NSURL(string: appStoreAppPath) {
            activityItems.append(appLink)
        }
        let shareSheet = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        shareSheet.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            if completed {
                completion?(activityType: activityType)
            }
        }
        viewController.presentViewController(shareSheet, animated: true, completion: nil)
    }
    
    public func rateApp(fromViewController viewController: UIViewController, iTunesItemIdentifier: Int) {
        guard let shareURL = NSURL(string: "\(ratingLinkPathPrefix)\(iTunesItemIdentifier)") else { return }
        UIApplication.sharedApplication().openURL(shareURL)
    }
    
    public func canRateApp() -> Bool {
        guard let shareURL = NSURL(string: ratingLinkPathPrefix) else { return false }
        return UIApplication.sharedApplication().canOpenURL(shareURL)
    }
    
    public func viewRelatedApp(fromViewController viewController: UIViewController, iTunesItemIdentifier: Int, storeProductViewDelegate: SKStoreProductViewControllerDelegate, completion: (() -> Void)? = nil) {
        showStoreProductView(fromViewController: viewController, iTunesItemIdentifier: iTunesItemIdentifier, storeProductViewDelegate: storeProductViewDelegate, completion: completion)
    }
    
}


// MARK: - Private functions

private extension SettingsActionService {
    
    func showStoreProductView(fromViewController viewController: UIViewController, iTunesItemIdentifier: Int, storeProductViewDelegate: SKStoreProductViewControllerDelegate, completion: (() -> Void)? = nil) {
        let store = SKStoreProductViewController()
        store.delegate = storeProductViewDelegate
        store.loadProductWithParameters([SKStoreProductParameterITunesItemIdentifier: iTunesItemIdentifier]) { success, error in
            viewController.presentViewController(store, animated: true) {
                completion?()
            }
        }
    }
    
}
