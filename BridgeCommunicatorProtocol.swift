import Foundation

protocol BridgeCommunicatorProtocol {
    init(_ viewController: WebAppViewController)
    func bridgeCommunication(_ command: String)
}
