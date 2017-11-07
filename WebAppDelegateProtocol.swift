import Foundation


@objc protocol WebAppDelegateProtocol {
    func baseUrl () -> URL
    func loadingView () -> UIView?
    @objc optional func bridgePrefix () -> String
}
