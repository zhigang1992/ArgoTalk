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
    func flatMap<U>(function: T->Parser<U>) -> Parser<U> {
        return Parser<U> { input in
            if let result = self.parse(input) {
                return function(result).parse(input)
            }
            return nil
        }
    }
}

let genderParser = Parser<User.Gender> { input in
    guard let string = input as? String else { return nil }
    if string == "male" { return .Male }
    if string == "female" { return .Female }
    return nil
}

genderParser.parse("male")
genderParser.parse("female")
genderParser.parse("not gender")
genderParser.parse(123)






