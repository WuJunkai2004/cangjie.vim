// Language: Cangjie
// Filename: example.cj

/*
 * 这是一个多行注释的例子。
 * 它可以包含 TODO, FIXME, XXX 等关键字。
 * TODO: 实现更复杂的功能。
 */
package demo

import std.core

// 定义一个公开的结构体
struct Point {
    var x: Float64 = 0.0
    var y: Float64 = 0.0
    init() {} // 默认构造函数
    init(x: Float64, y: Float64) {
        this.x = x
        this.y = y
        this.
    }
}

// 定义一个私有的枚举
enum Color {
    Red | Green | Blue
}

// 主函数，程序的入口
main() {
    // 1. 变量和常量声明
    const PI: Float64 = 3.14159
    let name: String = "仓颉"
    var age: Int32 = 1 // 这是一个可变变量

    // 2. 内置类型和字面量
    let is_core: Bool = true
    let tag: Rune = 'x'
    let `special_name`: String = "特殊标识符"

    // 3. 各种数字格式
    let decimal_int = 1_000_000
    let float_num = 123.456
    let science_num = 6.022e23
    let hex_num = 0xFF_AB
    let binary_num = 0b1010_0101
    let octal_num = 0o755
    var a = 100i8  // a is 100 with type Int8
    var b = 0x10u64 // b is 16 with type UInt64
    var c = 0o432i32  // c is 282 with type Int32
    var d = r'x' // d is 120 with type UInt8
    var e = r'\n' // e is 10 with type UInt8
    var f = r'\u{78}' // f is 120 with type UInt8
    let g: Float32 = 3.14f64
    let h: Float32 = 2e3
    let i: Float32 = 2.4e-1
    let j: Float64 = .123e2
    let k: Float64 = 0x1.1p0
    let l: Float64 = 0x1p2
    let m: Float64 = 0x.2p4

    // 4. 字符串和插值
    // NOTE: 根据你的语法文件，${} 符号本身可能不会高亮，但内部的表达式会
    let message = "你好, ${name}! 你的年龄是 ${age}."
    let path = '/usr/local/bin'
    let multiline_string = """
    这是一个多行字符串。
    PI 的值约等于 ${PI}。
    """
    let raw_string = #"原始字符串 C:\Users\Admin 不会转义 \"#

    // 5. 控制流语句
    if(age >= 18 && is_core) {
        println("已成年")
    } else {
        println("未成年")
    }

    // for 循环和范围操作符
    for(i in 0..5) {
        // do something
    }

    // match 语句
    let color = Color.Red
    match(color){
        case Red =>
            println("红色")
        case Green =>
            println("绿色")
        case Blue =>
            println("蓝色")
    }

    // 6. Option 类型
    var maybe_num: Option<Int32> = Some(42)
    match(maybe_num){
        case Some(num) =>
            println("数字是: ${num}")
        case None =>
            println("没有数字")
    }

    // 7. 函数调用
    let p = Point(1.0, 2.0)
    let description = describe(p)
    println(description)
}

// 一个简单的函数，展示参数和返回类型
func describe(p: Point): String {
    // BUG: 这里的格式化可能不正确
    return "Point at (${p.x}, ${p.y})"
}

