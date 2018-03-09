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

public class SettingsActionService: NSObject {
    
    // MARK: - Internal properties
    
    var deviceInfoService = DeviceInfoService()
    
    
    // MARK: - Constants
    
    fileprivate let appLinkPathPrefix = "itms-apps://itunes.apple.com/app/id"
    
    
    // MARK: - Public Functions
    
    /**
     Presents mail compose view controller prefilled with helpful information.
     
     - parameters:
        - viewController:       Originating view controller that can be used to present
        - emailAddresses:       Recipients for feedback email
        - logAttachment:        Plain text data object for logs
        - imageAttachments:     Dictionary of image names and image data objects
        - mailComposeDelegate:  Optional delegate for responding to mail completing. If `nil`,
            the service objecct will be the delegate.
     */
    public func sendFeedback(from viewController: UIViewController, emailAddresses: [String], logAttachment: Data? = nil, imageAttachments: [String: Data] = [:], mailComposeDelegate: MFMailComposeViewControllerDelegate? = nil) {
        guard MFMailComposeViewController.canSendMail() else { return }
        let feedback = MFMailComposeViewController()
        feedback.mailComposeDelegate = mailComposeDelegate ?? self
        feedback.setToRecipients(emailAddresses)
        feedback.setSubject("Some thoughts on \(deviceInfoService.appName)")
        let supportInfo = "iOS \(deviceInfoService.osVersion) on \(deviceInfoService.deviceModelName) \nLocale: \(deviceInfoService.locale) (\(deviceInfoService.language)) \n\(deviceInfoService.appNameWithVersion)"
        let messageText = "Here are my thoughts:\n\n\n\n\n\n--------------------------------\nDeveloper Support Information\n\n\(supportInfo)\n--------------------------------\n"
        feedback.setMessageBody(messageText, isHTML: false)
        if let logAttachment = logAttachment {
            feedback.addAttachmentData(logAttachment, mimeType: "text/txt", fileName: "log.txt")
        }
        imageAttachments.forEach { attachment in
            feedback.addAttachmentData(attachment.value, mimeType: "image/png", fileName: attachment.key + ".png")
        }
        viewController.present(feedback, animated: true, completion: nil)
    }
    
    /**
     Evaluates whether the device is able to send email.
     
     - returns: True if device can send email
     */
    public func canSendFeedback() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    /**
     Launches share sheet with message and link to app.
     
     - parameters:
        - viewController:   Originating view controller that can be used to present
        - sourceView:       View that was touched triggering the share, used for iPad popover anchor
        - message:          Optional custom message. If `nil`, message will be "Check out [App Name],
            an app I’ve really been enjoying."
        - appStoreAppPath:  String of link to app in app store
        - completion:       Optional closure to execute when user finishes sharing
     */
    public func shareApp(from viewController: UIViewController, sourceView: Any?, message: String? = nil, appStoreAppPath: String, completion: ((_ activityType: String?) -> Void)? = nil) {
        let message = message ?? "Check out \(deviceInfoService.appName), an app I’ve really been enjoying."
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
        } else if let sourceView = sourceView as? UIView {
            shareSheet.popoverPresentationController?.sourceView = sourceView.superview
            shareSheet.popoverPresentationController?.sourceRect = sourceView.frame
        }
        viewController.present(shareSheet, animated: true, completion: nil)
    }
    
    /**
     Open App Store to app for users to leave review.
     
     - parameters:
        - viewController:       Originating view controller that can be used to present
        - iTunesItemIdentifier: ID of app in iTunes Connect
     */
    public func rateApp(from viewController: UIViewController, iTunesItemIdentifier: Int) {
        guard let appURL = appLink(with: iTunesItemIdentifier, forReview: true) else { return }
        UIApplication.shared.openURL(appURL)
    }
    
    /**
     Evaluates whether the device is able to open the app store.
     
     - returns: True if device can open link to App Store
     */
    public func canLaunchAppStore() -> Bool {
        guard let shareURL = URL(string: appLinkPathPrefix) else { return false }
        return UIApplication.shared.canOpenURL(shareURL)
    }
    
    /**
     Either shows a store product view controller for the related app or opens the App Store to the app.
     
     - parameters:
        - viewController:           Originating view controller that can be used to present
        - iTunesItemIdentifier:     ID of app in iTunes Connect
        - storeProductViewDelegate: Optional delegate to handle the user closing teh store product view.
            If `nil`, the service object will be the delegate.
        - launchAppStore:           Flag to determine whether to open the App Store or display product view.
            Defaults to `false`.
        - completion:               Optional closure to execute after product view is presented
     */
    public func viewRelatedApp(from viewController: UIViewController, iTunesItemIdentifier: Int, storeProductViewDelegate: SKStoreProductViewControllerDelegate? = nil, launchAppStore: Bool = false, completion: (() -> Void)? = nil) {
        if launchAppStore {
            guard let appURL = appLink(with: iTunesItemIdentifier) else { return }
            UIApplication.shared.openURL(appURL)
        } else {
            let store = SKStoreProductViewController()
            store.delegate = storeProductViewDelegate ?? self
            store.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: iTunesItemIdentifier]) { success, error in
                viewController.present(store, animated: true) {
                    completion?()
                }
            }
        }
    }
    
    /**
     Opens Settings to app-specific settings.
     */
    public func openAppSettings() {
        SettingsActionService.openAppSettings()
    }
    
    public static func openAppSettings() {
        let settingsURL = URL(string: UIApplicationOpenSettingsURLString)!
        UIApplication.shared.openURL(settingsURL)
    }
    
}


// MARK: - Mail compose delegate

extension SettingsActionService: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - Store product view controller delegate

extension SettingsActionService: SKStoreProductViewControllerDelegate {
    
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}


// MARK: - Private functions

private extension SettingsActionService {
    
    func appLink(with iTunesItemIdentifier: Int, forReview: Bool = false) -> URL? {
        var urlString = "\(appLinkPathPrefix)\(iTunesItemIdentifier)"
        if forReview {
            urlString += "?action=write-review"
        }
        guard let appURL = URL(string: urlString) else { return nil }
        return appURL
    }
    
}


// MARK: - UIAlertController settings action

public extension UIAlertController {
    
    public func addSettings() {
        addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings button title"), style: .default) { _ in
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            SettingsActionService.openAppSettings()
        })
    }
    
}
