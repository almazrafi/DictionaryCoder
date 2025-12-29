import Foundation

public struct Mutex<Value>: @unchecked Sendable {

    private let storage: MutexStorage<Value>

    public init(value: Value) {
        self.storage = MutexStorage(value: value)
    }

    public borrowing func withLock<Result>(
        _ body: (inout Value) throws -> Result
    ) rethrows -> Result {
        storage.lock()

        defer {
            storage.unlock()
        }

        return try body(&storage.value)
    }

    public borrowing func withLockIfAvailable<Result>(
        _ body: (inout Value) throws -> Result
    ) rethrows -> Result? {
        guard storage.tryLock() else {
            return nil
        }

        defer {
            storage.unlock()
        }

        return try body(&storage.value)
    }
}
