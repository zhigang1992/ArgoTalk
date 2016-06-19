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

infix operator <|> { associativity left }
func <|><T>(left: Parser<T>, right: Parser<T>) -> Parser<T> {
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

let genderParser: Parser<User.Gender> = parse(string: "male", into: .Male)
    <|> parse(string: "female", into: .Female)
    <|> parse(string: "boy", into: .Male)
    <|> parse(string: "girl", into: .Female)

let _userParser: Parser<User> = Parser<User> { input in
    guard let dictionary = input as? NSDictionary else { return nil }
    guard let id = dictionary["id"].flatMap(intParser.parse) else { return nil }
    guard let name = dictionary["name"].flatMap(stringParser.parse) else { return nil }
    guard let gender = dictionary["gender"].flatMap(genderParser.parse) else { return nil }
    return User(id: id, name: name, gender: gender)
}

func dictionaryParser<T>(key: String, parser: Parser<T>) -> Parser<T> {
    return Parser<T> { input in
        guard let dictionary = input as? NSDictionary else { return nil }
        return dictionary[key].flatMap(parser.parse)
    }
}

let userParser: Parser<User> = Parser<User> { input in
    let idParser = dictionaryParser("id", parser: intParser)
    let nameParser = dictionaryParser("name", parser: stringParser)
    let genderP = dictionaryParser("gender", parser: genderParser)
    
    guard let id = idParser.parse(input) else { return nil }
    guard let name = nameParser.parse(input) else { return nil }
    guard let gender = genderP.parse(input) else { return nil }
    return User(id: id, name: name, gender: gender)
}

extension Parser {
    func apply<U>(applicative: Parser<T->U>) -> Parser<U> {
        return applicative.flatMap({self.map($0)})
    }
}

let assemable: Int->String->User.Gender->User = { id in
    { name in
        { gender in
            return User(id: id, name: name, gender: gender)
        }
    }
}



print(userParser.parse(userData))




