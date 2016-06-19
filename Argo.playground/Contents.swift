import Foundation

//: > Mission - Parse userData into a User

let userData = [
    "id": 123,
    "name": "Kyle Fang",
    "gender": "male",
]

struct User {
    enum Gender {
        case Male
        case Female
    }
    let id: Int
    let name: String
    let gender: Gender
}

struct Parser<T> {
    let parse: AnyObject -> T?
}

let stringParser = Parser { $0 as? String }

let numberParser = Parser { $0 as? Double }

extension Parser {
    func map<U>(function: T->U) -> Parser<U> {
        return Parser<U> { input in
            if let result = self.parse(input) {
                return function(result)
            }
            return nil
        }
    }
}

let intParser = numberParser.map(Int.init)

extension Parser {
    static func unit(value: T) -> Parser<T> {
        return Parser { _ in value }
    }
    
    static func failed() -> Parser<T> {
        return Parser { _ in nil }
    }
    
    func flatMap<U>(function: T->Parser<U>) -> Parser<U> {
        return Parser<U> { input in
            if let result = self.parse(input) {
                return function(result).parse(input)
            }
            return nil
        }
    }
}

let _genderParser = Parser<User.Gender> { input in
    guard let string = input as? String else { return nil }
    if string == "male" { return .Male }
    if string == "female" { return .Female }
    return nil
}

let __genderParser: Parser<User.Gender> = stringParser.flatMap({ string in
    if string == "male" { return .unit(.Male) }
    if string == "female" { return .unit(.Female) }
    return .failed()
})

func or<T>(left:Parser<T>, _ right: Parser<T>) -> Parser<T> {
    return Parser<T> { input in
        if let result = left.parse(input) {
            return result
        }
        return right.parse(input)
    }
}

func parse<T>(string string: String, into value:T) -> Parser<T> {
    return stringParser.flatMap({ string == $0 ? .unit(value) : .failed() })
}

let genderParser: Parser<User.Gender> = or(
    parse(string: "male", into: .Male),
    parse(string: "female", into: .Female)
)

genderParser.parse("male")
genderParser.parse("female")
genderParser.parse("not gender")
genderParser.parse(123)






