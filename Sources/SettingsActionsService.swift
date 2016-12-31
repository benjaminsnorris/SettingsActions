/*
 |  _   ____   ____   _
 | | |‾|  ⚈ |-| ⚈  |‾| |
 | | |  ‾‾‾‾| |‾‾‾‾  | |
 |  ‾        ‾        ‾
 */

import Foundation
import MessageUI
import StoreKit
import DeviceInfo

public struct SettingsActionService {
    
    // MARK: - Internal properties
    
    var deviceInfoService = DeviceInfoService()
    
    
    // MARK: - Constants
    
    fileprivate let appLinkPathPrefix = "itms-apps://itunes.apple.com/app/id"
    
    
    // MARK: - Initializers
    
    public init() { }
    
    
    // MARK: - Public Functions
    
    public func sendFeedback(from viewController: UIViewController, emailAddresses: [String], mailComposeDelegate: MFMailComposeViewControllerDelegate) {
        guard MFMailComposeViewController.canSendMail() else { return }
        let feedback = MFMailComposeViewController()
        feedback.mailComposeDelegate = mailComposeDelegate
        feedback.setToRecipients(emailAddresses)
        feedback.setSubject("Some thoughts on \(deviceInfoService.appName)")
        let supportInfo = "iOS \(deviceInfoService.osVersion) on \(deviceInfoService.deviceModelName) \nLocale: \(deviceInfoService.locale) (\(deviceInfoService.language)) \n\(deviceInfoService.appNameWithVersion))"
        let messageText = "Here are my thoughts:\n\n\n\n\n\n--------------------------------\nDeveloper Support Information\n\n\(supportInfo)\n--------------------------------\n"
        feedback.setMessageBody(messageText, isHTML: false)
        viewController.present(feedback, animated: true, completion: nil)
    }
    
    public func shareApp(from viewController: UIViewController, sourceView: UIView?, message: String? = nil, appStoreAppPath: String, completion: ((_ activityType: String?) -> Void)? = nil) {
        let message = message ?? "Check out \(deviceInfoService.appName), an app I've really been enjoying."
        var activityItems: [Any] = [message]
        if let appLink = URL(string: appStoreAppPath) {
            activityItems.append(appLink as Any)
        }
        let shareSheet = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        shareSheet.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            if completed {
                completion?(activityType.map { $0.rawValue })
            }
        }
        if let barButton = sourceView as? UIBarButtonItem {
            shareSheet.popoverPresentationController?.barButtonItem = barButton
        } else if let sourceView = sourceView {
            shareSheet.popoverPresentationController?.sourceView = sourceView.superview
            shareSheet.popoverPresentationController?.sourceRect = sourceView.frame
        }
        viewController.present(shareSheet, animated: true, completion: nil)
    }
    
    public func rateApp(from viewController: UIViewController, iTunesItemIdentifier: Int) {
        guard let appURL = appLink(with: iTunesItemIdentifier) else { return }
        UIApplication.shared.openURL(appURL)
    }
    
    public func canRateApp() -> Bool {
        guard let shareURL = URL(string: appLinkPathPrefix) else { return false }
        return UIApplication.shared.canOpenURL(shareURL)
    }
    
    public func viewRelatedApp(from viewController: UIViewController, iTunesItemIdentifier: Int, storeProductViewDelegate: SKStoreProductViewControllerDelegate? = nil, completion: (() -> Void)? = nil) {
        if let storeProductViewDelegate = storeProductViewDelegate {
            showStoreProductView(from: viewController, iTunesItemIdentifier: iTunesItemIdentifier, storeProductViewDelegate: storeProductViewDelegate, completion: completion)
        } else {
            guard let appURL = appLink(with: iTunesItemIdentifier) else { return }
            UIApplication.shared.openURL(appURL)
        }
    }
    
}


// MARK: - Private functions

private extension SettingsActionService {
    
    func showStoreProductView(from viewController: UIViewController, iTunesItemIdentifier: Int, storeProductViewDelegate: SKStoreProductViewControllerDelegate, completion: (() -> Void)? = nil) {
        let store = SKStoreProductViewController()
        store.delegate = storeProductViewDelegate
        store.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: iTunesItemIdentifier]) { success, error in
            viewController.present(store, animated: true) {
                completion?()
            }
        }
    }
    
    func appLink(with iTunesItemIdentifier: Int) -> URL? {
        guard let appURL = URL(string: "\(appLinkPathPrefix)\(iTunesItemIdentifier)") else { return nil }
        return appURL
    }
    
}
