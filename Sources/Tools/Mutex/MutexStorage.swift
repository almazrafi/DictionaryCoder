import Foundation

import struct os.os_unfair_lock_t
import struct os.os_unfair_lock

import func os.os_unfair_lock_lock
import func os.os_unfair_lock_unlock
import func os.os_unfair_lock_trylock

internal final class MutexStorage<Value> {

    private let unfairLock = os_unfair_lock_t.allocate(capacity: 1)

    internal var value: Value

    internal init(value: consuming Value) {
        self.value = value

        unfairLock.initialize(to: os_unfair_lock())
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    internal func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    internal func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }

    internal func tryLock() -> Bool {
        os_unfair_lock_trylock(unfairLock)
    }
}
