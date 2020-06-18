# What's New in Swift
From Swift 4.0 to Swift 5.1

-   [Swift 4.0](https://github.com/ole/whats-new-in-swift-4)
-   [Swift 4.1](https://github.com/twostraws/whats-new-in-swift-4-1)
-   [Swift 4.2](https://github.com/twostraws/whats-new-in-swift-4-2)
-   [Swift 5.0](https://github.com/twostraws/whats-new-in-swift-5-0)
-   [Swift 5.1](https://github.com/twostraws/whats-new-in-swift-5-1)
-   [Swift 5.2](https://github.com/twostraws/whats-new-in-swift-5-2)


### Website

[What's New in Swift by Paul Hudson](https://www.whatsnewinswift.com/?from=5.0&to=5.1)

### Swift 5.0

#### Customizing string interpolation

```swift
protocol ExpressibleByStringInterpolation: ExpressibleByStringLiteral {
  associatedtype StringInterpolation: StringInterpolationProtocol = DefaultStringInterpolation where Self.StringLiteralType == Self.StringInterpolation.StringLiteralType
    init(stringInterpolation: Self.StringInterpolation)
}

protocol StringInterpolationProtocol {
  associatedtype StringLiteralType: _ExpressibleByBuiltinStringLiteral
  init(literalCapacity: Int, interpolationCount: Int)
  mutating func appendLiteral(_ literal: Self.StringLiteralType)
}

struct DefaultStringInterpolation: StringInterpolationProtocol {}

typealias String.StringInterpolation = DefaultStringInterpolation 
```

1.  想要格式化类、结构体或者枚举类型，扩展 `DefaultStringInterpolation`

```swift
struct User {
  var name: String
  var age: Int
}

extension DefaultStringInterpolation {
  mutating func appendInterpolation(_ value: User) {
    appendInterpolation("My name is \(value.name) and I'm \(value.age)")
  }
}

 let user = User(name: "Guybrush Threepwood", age: 33)
 let text = "User details: \(user)"
```

上面这个功能跟实现 `CustomStringConvertible` 协议从效果上是一样的，因为 `DefaultStringInterpolation`有下面这个方法。

```swift
struct DefaultStringInterpolation {
  mutating func appendInterpolation<T>(_ value: T) where T : CustomStringConvertible
}
```

但是存在比 `CustomStringConvertible` 更高级的用法

```swift
extension DefaultStringInterpolation {
  mutating func appendInterpolation(_ user: User, style: NumberFormatter.Style) {
    // ...
  }
}

 let user = User(name: "Guybrush Threepwood", age: 33)
 let text = "User details: \(user, style: .spellOut)"
```

`appendInterpolation` 方法跟别的方法一样，可以有多个参数、默认值、可变参数、有标签、有泛型、重载、闭包等，能多次调用 `appendLiteral`

2.  从插值字符串创建类实例

这里分两种，一种使用默认的 `StringInterpolation = DefaultStringInterpolation` , 一种是自定义 `StringInterpolation`

第一种情况你只要confirm to `ExpressibleByStringInterpolation` 并且实现下面这个方法

```swift
protocol ExpressibleByStringLiteral {
  init(stringLiteral value: String)
}
```

Swift 将自动使用`defaultstringinterpolation` 作为`StringInterpolation` ，并为`init(stringinterpolation:)` 提供一个实现，该实现将插值文本的内容传递给 `init(stringliteral:)`，因此不需要实现任何特定于 `ExpressibleByStringInterpolation` 的内容。

第二种情况你需要自定义 `StringInterpolation: StringInterpolationProtocol`

例如下面这个例子，在SwiftUI中用于字符串本地化

```swift
struct LocalizedStringKey: ExpressibleByStringLiteral, ExpressibleByStringInterpolation, CustomStringConvertible {
  static let localizedDict = [
    "I have many apples": "我有很多苹果",
    "I have %ld apples": "我有%ld个苹果"
  ]
    
  struct StringInterpolation: StringInterpolationProtocol {
    var format = ""
    var values = [CVarArg]()

    init(literalCapacity: Int, interpolationCount: Int) {
      format.reserveCapacity(literalCapacity * 2)
    }

    mutating func appendLiteral(_ literal: String) {
      format.append(literal)
    }
        
    mutating func appendInterpolation(_ num: Int) {
      format.append("%ld")
      values.append(num)
    }
  }
  
  var description: String { return localizedString }
  
  let localizedString: String
    
  init(stringLiteral value: String) {
    localizedString = LocalizedStringKey.localizedDict[value] ?? value
  }
    
  init(stringInterpolation: StringInterpolation) {
    let format = LocalizedStringKey.localizedDict[stringInterpolation.format] ?? stringInterpolation.format
    localizedString = String(format: format, arguments: stringInterpolation.values)
  }
}

let num = 10
let localization1: LocalizedStringKey = "I have \(num) apples"
print(localization1) // 我有10个苹果

let localization2: LocalizedStringKey = "I have many apples"
print(localization2) // 我有很多苹果

let localization3: LocalizedStringKey = "I have 10 apples"
print(localization3) // I have 10 apples
```

### Swift 5.1

增加下面3个新特性 in "Whats-New-In-Swift-5-1.playground"

-   Dynamic Member Lookup
-   Property Wrappers
-   SIMD

#### Property Wrappers实战 - UserDefaults

```swift
fileprivate typealias Key = UserDefaultsService.Key

@propertyWrapper
struct UserDefaultWrapper<T> {
    private let key: Key
    private let defaultValue: T?
    var wrappedValue: T? {
        get {
            UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
    
    // 注意 wrappedValue 参数必须在前，其它参数在后
    fileprivate init(wrappedValue: T?, _ key: Key) {
        self.key = key
        self.defaultValue = wrappedValue
    }
}

struct UserDefaultsService {
    enum Key: String {
        case refreshDate = "refresh_date"
        case fontSize = "font_size"
    }
    
    @UserDefaultWrapper(Key.refreshDate)
    static var refreshDate: Date? = nil
    
    @UserDefaultWrapper(Key.fontSize)
    static var fontSize: Int! = 15
}
```

