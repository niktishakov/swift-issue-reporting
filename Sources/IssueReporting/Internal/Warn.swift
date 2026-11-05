#if canImport(Darwin)
  import Darwin
#elseif os(WASI)
  import Foundation
#elseif canImport(Glibc)
  @preconcurrency import Glibc
#elseif canImport(Musl)
  @preconcurrency import Musl
#elseif canImport(Android)
  @preconcurrency import Android
#elseif os(Windows)
  import ucrt
#endif

@usableFromInline
func printError(_ message: String) {
  #if os(Windows)
    // NB: `stderr` is a C macro in the Windows CRT, so Swift can't see it.
    fputs("\(message)\n", __acrt_iob_func(2))
  #else
    fputs("\(message)\n", stderr)
  #endif
}
