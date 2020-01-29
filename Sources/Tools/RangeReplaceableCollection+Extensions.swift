import Foundation

extension RangeReplaceableCollection {

    // MARK: - Instance Methods

    internal func appending<T: Collection>(contentsOf collection: T) -> Self where Self.Element == T.Element {
        return self + collection
    }

    internal func appending(_ element: Element) -> Self {
        return appending(contentsOf: [element])
    }
}
