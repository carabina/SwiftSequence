# SwiftSequence
SwiftSequence is a framework of extensions to `SequenceType`, that provides functional, lightweight methods, similar to Python's itertools.

SwiftSequence adds one new protocol: `LazySequenceType`. This protocol has all of the same requirements as `SequenceType`, but anything that conforms to it is assumed to be lazily evaluated.

Every function and method has both a lazy and an eager version (if possible). When using a method, if the underlying sequence conforms to `LazySequenceType`, the method used will be the lazy version. If the sequence is eager, the eager method will be used.

All sequences returned by lazy methods conform to `LazySequenceType`, and these standard library structs have been made to conform, also:

```swift
extension LazySequence                : LazySequenceType {}
extension LazyForwardCollection       : LazySequenceType {}
extension LazyBidirectionalCollection : LazySequenceType {}
extension LazyRandomAccessCollection  : LazySequenceType {}
extension FilterSequenceView          : LazySequenceType {}
extension FilterCollectionView        : LazySequenceType {}
extension MapSequenceView             : LazySequenceType {}
extension MapCollectionView           : LazySequenceType {}
extension Zip2                        : LazySequenceType {}
extension EnumerateSequence           : LazySequenceType {}
```

To make an eager sequence lazy, the `lazy()` function can be used:

```swift
lazy([1, 2, 3])
  .hop(1)

// 1, 3
```

And to "thunk" a lazy sequence, (to cause it to be evaluated), the `array()` method can be used:

```swift
lazy([1, 2, 3])
  .hop(1)
  .array()

// [1, 3]
```

SwiftSequence has no dependancies beyond the Swift standard library.

## Contents ##

- [ScanReduce] (#scanreduce)
- [TakeDrop] (#takedrop)
- [HopJump] (#hopjump)
- [Interpose] (#interpose)
- [Combinations] (#combinations)
- [Permutations] (#permutations)
- [GenericGenerators] (#genericgenerators)
- [Cycle] (#cycle)
- [Categorise] (#categorise)
- [ChunkWindowSplit] (#chunkwindowsplit)
- [Enumerate] (#enumerate)
- [Finding] (#finding)
- [NestedSequences] (#nestedsequences)
- [Zip] (#zip)

## ScanReduce ##

### Reduce ###

```swift
func reduce (@noescape combine: (Generator.Element, Generator.Element) -> Generator.Element)
```
 Return the result of repeatedly calling combine with an accumulated value
 initialised to the first element of self and each element of self, in turn, i.e.

 ```swift
 [1, 2, 3].reduce(+) // 6
 ```

This function works the same as the standard library reduce, except it takes the initial value to be the first element of `self` It returns an optional, which is `nil` if `self` is empty.

### Scan ###
Return an array where every value is equal to combine called on the previous element, and the current element. The first element is taken to be initial.

```swift
[1, 2, 3].scan(0, combine: +)
 
[1, 3, 6]
```

This function has a lazy and an eager version. The eager returns an array, lazy returns a sequence, generated on-demand. There is also, like reduce, a version that takes the first element of the sequence to be `initial`:

```swift
[1, 2, 3, 4, 5].scan(+)

[1, 3, 6, 10, 15]
```

This also is evaluated lazily if the sequence it is called on is lazy.

## TakeDrop ##

### Take ###

This function returns the first `n` elements of self:

```swift
[1, 2, 3, 4, 5].take(3)

[1, 2, 3]
```

It has an eager, and a lazy version.

### Drop ###

This function returns self with the first `n` elements dropped:

```swift
[1, 2, 3, 4, 5].drop(3)

[4, 5]
```

It is *not* analogous to slicing: the function walks over `n` elements of self in order to return the rest, so it is far less efficient than `ArraySlice` (*O(n)* vs *O(1)*). However, it has the advantage of being capable of lazy evaluation. Combined with `take`, it can allow easy manipulation of infinite sequences:

```swift
(1...)
  .drop(10)
  .take(10)
  .array()

[11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
```

### TakeWhile ###

This function returns all of the elements of `self` up until an element returns false for `predicate`:

```swift
[1, 2, 3, 4, 5, 2].takeWhile { $0 < 4 }

[1, 2, 3]
```

Note that it's not the same as filter: if any elements return true for the predicate *after* the first element that returns false, they're still not returned. This function has both a lazy and an eager version.

## HopJump ##
## Interpose ##
## Combinations ##
## Permutations ##
## GenericGenerators ##
## Cycle ##
## Categorise ##
## ChunkWindowSplit ##
## Enumerate ##
## Finding ##
## NestedSequences ##
## Zip ##
