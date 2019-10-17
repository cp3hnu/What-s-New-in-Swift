/*:
[< Previous](@previous)           [Home](Introduction)

 ## SIMD
 [SE-0229](https://github.com/apple/swift-evolution/blob/master/proposals/0229-simd.md) A Better API for Vector Programming
 
 Types for fixed-size SIMD vectors and matrices:
 SIMD2<T>, SIMD3<T>, SIMD4<T>, SIMD8<T>, SIMD16<T>, SIMD32<T>, SIMD64<T>  Most standard integer and floating-point types can be used as element types
*/

import Foundation

// Initialize from array literals
let x: SIMD4<Int> = [1,2,3,4]
let y: SIMD4<Int> = [3,2,1,0]

// Pointwise equality, inequality, and ordered comparisons
// Return SIMDMask type
let gr = x .> y
print(gr)
// gr : SIMDMask<SIMD4<Int>>(false, false, true, true)

// Boolean operations on SIMDMasks
let lteq = .!gr
print(lteq)
// lteq : SIMDMask<SIMD4<Int>>(true, true, false, false)

/*:
&nbsp;

[< Previous](@previous)           [Home](Introduction)
*/
