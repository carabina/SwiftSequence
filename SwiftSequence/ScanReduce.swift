// MARK: - Eager

public extension SequenceType {
  
  // MARK: Reduce1
  
  /// Return the result of repeatedly calling combine with an accumulated value
  /// initialized to the first element of self and each element of self, in turn, i.e.
  /// return combine(combine(...combine(combine(self[0], self[1]),
  /// self[2]),...self[count-2]), self[count-1]).
  /// ```swift
  /// [1, 2, 3].reduce(+) // 6
  /// ```
  
  func reduce
    (@noescape combine: (Generator.Element, Generator.Element) -> Generator.Element)
    -> Generator.Element? {
      var g = self.generate()
      return g.next().map {
        (var accu) in
        while let next = g.next() { accu = combine(accu, next) }
        return accu
      }
  }
  
  // MARK: Scan
  
  /// Return an array where every value is equal to combine called on the previous
  /// element, and the current element. The first element is taken to be initial.
  /// ```swift
  /// [1, 2, 3].scan(0, combine: +)
  /// 
  /// [1, 3, 6]
  /// ```
  
  func scan<T>(var initial: T, @noescape combine: (T, Generator.Element) -> T) -> [T] {
    return self.map {
      initial = combine(initial, $0)
      return initial
    }
  }
  
  // MARK: Scan1
  
  /// Return an array where every value is equal to combine called on the previous
  /// element, and the current element.
  /// ```swift
  /// [1, 2, 3].scan(+)
  ///
  /// [1, 3, 6]
  /// ```
  
  func scan(@noescape combine: (Generator.Element, Generator.Element) -> Generator.Element) -> [Generator.Element] {
    var initial: Generator.Element?
    return self.map {
      element in
      initial = initial.map{combine($0, element)} ?? element
      return initial!
    }
  }
}

// MARK: - Lazy

// MARK: Scan

public struct ScanGen<G : GeneratorType, T> : GeneratorType {
  
  private let combine: (T, G.Element) -> T
  private var initial: T
  private var g: G
  
  public mutating func next() -> T? {
    return g.next().map {
      initial = combine(initial, $0)
      return initial
    }
  }
}

public struct LazyScanSeq<S : SequenceType, T> : LazySequenceType {
  
  private let seq    : S
  private let combine: (T, S.Generator.Element) -> T
  private let initial: T
  
  public func generate() -> ScanGen<S.Generator, T> {
    return ScanGen(combine: combine, initial: initial, g: seq.generate())
  }
}

public extension LazySequenceType {
  
  /// Return a lazy sequence where every value is equal to combine called on the previous
  /// element, and the current element. The first element is taken to be initial.
  /// ```swift
  /// lazy([1, 2, 3]).scan(0, combine: +)
  ///
  /// 1, 3, 6
  /// ```
  
  func scan<T>(initial: T, combine: (T, Generator.Element) -> T) -> LazyScanSeq<Self, T> {
    return LazyScanSeq(seq: self, combine: combine, initial: initial)
  }
}

// MARK: Scan1

public struct Scan1Gen<G : GeneratorType> : GeneratorType {
  
  private let combine: (G.Element, G.Element) -> G.Element
  private var accu: G.Element?
  private var g: G
  
  public mutating func next() -> G.Element? {
    return g.next().map{
      element in
      accu = accu.map{ combine($0, element) } ?? element
      return accu!
    }
  }
}

public struct LazyScan1Seq<S : SequenceType> : LazySequenceType {
  
  private let seq: S
  private let combine: (S.Generator.Element, S.Generator.Element) -> S.Generator.Element
  
  public func generate() -> Scan1Gen<S.Generator> {
    return Scan1Gen(combine: combine, accu: nil, g: seq.generate())
  }
}

public extension LazySequenceType {
  
  /// Return a lazy sequence where every value is equal to combine called on the previous
  /// element, and the current element.
  /// ```swift
  /// lazy([1, 2, 3]).scan(+)
  ///
  /// 1, 3, 6
  /// ```
  
  func scan(combine: (Generator.Element, Generator.Element) -> Generator.Element)
    -> LazyScan1Seq<Self> {
    return LazyScan1Seq(seq: self, combine: combine)
  }
}