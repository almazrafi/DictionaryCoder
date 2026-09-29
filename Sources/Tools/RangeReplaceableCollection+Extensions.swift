extension RangeReplaceableCollection {

    // MARK: - Instance Methods

    @inline(__always)
    internal func appending<T: Collection>(contentsOf collection: T) -> Self where Self.Element == T.Element {
        self + collection
    }

    @inline(__always)
    internal func appending(_ element: Element) -> Self {
        appending(contentsOf: [element])
    }
}
