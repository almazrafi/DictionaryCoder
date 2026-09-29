extension Optional {

    // MARK: - Instance Properties

    @inline(__always)
    internal var isNil: Bool {
        self == nil
    }
}
