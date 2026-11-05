#if canImport(Darwin) || os(WASI)
  import Foundation

  typealias Lock = NSLock
  typealias RecursiveLock = NSRecursiveLock
#else
  #if canImport(Glibc)
    import Glibc
  #elseif canImport(Musl)
    import Musl
  #elseif canImport(Android)
    import Android
  #elseif os(Windows)
    import WinSDK
  #endif
  /// Used where `NSLock` is used on Darwin. A recursive lock also works as a plain one.
  typealias Lock = RecursiveLock

  /// A recursive lock, like `NSRecursiveLock`, that does not depend on Foundation.
  final class RecursiveLock: @unchecked Sendable {
    #if os(Windows)
      private let mutex = UnsafeMutablePointer<CRITICAL_SECTION>.allocate(capacity: 1)

      init() {
        InitializeCriticalSection(self.mutex)
      }

      deinit {
        DeleteCriticalSection(self.mutex)
        self.mutex.deallocate()
      }

      func lock() {
        EnterCriticalSection(self.mutex)
      }

      func unlock() {
        LeaveCriticalSection(self.mutex)
      }
    #else
      private let mutex = UnsafeMutablePointer<pthread_mutex_t>.allocate(capacity: 1)

      init() {
        var attributes = pthread_mutexattr_t()
        pthread_mutexattr_init(&attributes)
        pthread_mutexattr_settype(&attributes, Int32(PTHREAD_MUTEX_RECURSIVE))
        pthread_mutex_init(self.mutex, &attributes)
        pthread_mutexattr_destroy(&attributes)
      }

      deinit {
        pthread_mutex_destroy(self.mutex)
        self.mutex.deallocate()
      }

      func lock() {
        pthread_mutex_lock(self.mutex)
      }

      func unlock() {
        pthread_mutex_unlock(self.mutex)
      }
    #endif
  }
#endif
