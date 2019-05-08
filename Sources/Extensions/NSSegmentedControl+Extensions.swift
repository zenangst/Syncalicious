import Cocoa

typealias EnumCase = CaseIterable & RawRepresentable & Equatable

extension NSSegmentedControl {
  func setSelected<T: EnumCase>(_ selected: Bool, with target: T) {
      setSelected(selected,
                  forSegment: Array(type(of: target).allCases)
                    .firstIndex(where: { $0 == target }) ?? 0)
  }
}
