//
//  PubliserTests.swift
//  DictionaryCoder Tests macOS
//
//  Created by Jason Jobe on 8/5/22.
//  Copyright © 2022 Almaz Ibragimov. All rights reserved.
//

import XCTest
import Combine
@testable import DictionaryCoder

extension DictionaryDecoder: TopLevelDecoder {
    
}

class PubliserTests: XCTestCase {

    private(set) var decoder: DictionaryDecoder!

    override func setUpWithError() throws {
        decoder = .init()
    }
    
    func testCombineDecode() throws {
        Just(json)
            .decode(type: Customer.self, decoder: decoder)
            .sink(
                receiveCompletion: {
                    print($0)
                },
                receiveValue: {
                    print($0)
                })
            .cancel()
    }

}

let json: [String: Any] = [
    "id": 0,
    "name": "Jose",
    "phone": "tel:01-321-555-5555"
]

struct Customer: Codable {
    let id: Int
    let name: String
    let phone: URL
}

//class MyViewModel: ObservableObject {
//    @Published var customers: [Customer] = []
//    private var cancellables = [AnyCancellable]()
//
//    init() {
//        Just(Data()).setFailureType(to: Error.self)
//        .decode(type: [Customer].self, decoder: JSONDecoder())
//        .replaceError(with: .init)
//        .receive(on: DispatchQueue.main)
//        .sink { [weak self] newCustomers in
//            self?.customers = newCustomers
//        }
//        .store(in: &cancellables)
//    }
//}
