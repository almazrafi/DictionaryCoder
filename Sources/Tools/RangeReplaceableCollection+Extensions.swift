extension RangeReplaceableCollection {

    // MARK: - Instance Methods

    @inline(__always)
    internal func appending(_ element: Element) -> Self {
        var collection = self

        collection.append(element)

        return collection
    }
}
