import Foundation

extension Optional {

    // MARK: - Instance Properties

    internal var isNil: Bool {
        self == nil
    }
}

extension Optional where Wrapped: Collection {

    // MARK: - Instance Properties

    internal var isEmptyOrNil: Bool {
        self?.isEmpty ?? true
    }
}
