import Foundation

extension RangeReplaceableCollection {

    // MARK: - Instance Methods

    internal func appending<T: Collection>(contentsOf collection: T) -> Self where Self.Element == T.Element {
        self + collection
    }

    internal func appending(_ element: Element) -> Self {
        appending(contentsOf: [element])
    }
}
