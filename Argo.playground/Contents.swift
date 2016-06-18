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

