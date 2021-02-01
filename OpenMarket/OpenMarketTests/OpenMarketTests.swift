//
//  OpenMarketTests.swift
//  OpenMarketTests
//
//  Created by 김동빈 on 2021/01/25.
//

import XCTest
@testable import OpenMarket

class OpenMarketTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
    }

    func testMakeItemsListURL() throws {
        // 1. given
        let expectResult = URL(string: "https://camp-open-market.herokuapp.com/items/1")
        
        // 2. when
        let url = try URLManager.makeURL(type: .itemsListPage(1))
        
        // 3. then
        XCTAssertEqual(url, expectResult, "Making URL is Failed")
    }
    
    func testMakeRegistItemURL() throws {
        // 1. given
        let expectResult = URL(string: "https://camp-open-market.herokuapp.com/item")
        
        // 2. when
        let url = try URLManager.makeURL(type: .registItem)
        
        // 3. then
        XCTAssertEqual(url, expectResult, "Making URL is Failed")
    }
    
    func testMakeItemIdURL() throws {
        // 1. given
        let expectResult = URL(string: "https://camp-open-market.herokuapp.com/item/66")
        
        // 2. when
        let url = try URLManager.makeURL(type: .itemId(66))
        
        // 3. then
        XCTAssertEqual(url, expectResult, "Making URL is Failed")
    }
    
    // MARK: Mock 데이터 테스트
    func testItemListDecode() throws {
        // 1. given
        var mockItemList: Items?
        guard let jsonData = NSDataAsset(name: "items") else { return }
        
        // 2. when
        mockItemList = try JSONDecoder().decode(Items.self, from: jsonData.data)
        
        // 3. then
        XCTAssertEqual(mockItemList?.page, 1)
        XCTAssertEqual(mockItemList?.items[0].title, "MacBook Air")
        XCTAssertEqual(mockItemList?.items[0].id, 1)
        XCTAssertEqual(mockItemList?.items[1].title, "MacBook Pro")
    }
    
    func testItemDecode() throws {
        // 1. given
        var mockItem: Item?
        guard let jsonData = NSDataAsset(name: "item") else { return }
        
        // 2. when
        mockItem = try JSONDecoder().decode(Item.self, from: jsonData.data)
        
        // 3. then
        XCTAssertEqual(mockItem?.id, 1)
        XCTAssertEqual(mockItem?.title, "MacBook Air")
        XCTAssertEqual(mockItem?.price, 1290000)
    }
    
    func testIdDecode() throws {
        // 1. given
        var mockItem: ItemToDelete?
        guard let jsonData = NSDataAsset(name: "id") else { return }
        
        // 2. when
        mockItem = try JSONDecoder().decode(ItemToDelete.self, from: jsonData.data)
        
        // 3. then
        XCTAssertEqual(mockItem?.id, 1)
    }
    
    // MARK: APIManager 테스트
    func testDecodeItemsList() throws {
        // 1. given
        let url = try URLManager.makeURL(type: .itemsListPage(1))
        var itemsList: Items?
        let expectation = XCTestExpectation(description: "Wait Decoding")

        // 2. when
        APIManager<Items>.handleRequest(object: nil, url: url, httpMethod: .get) { result in
            switch result {
            case .success(let object):
                itemsList = object as? Items
            case .failure(let error):
                print(error)
                XCTFail("Failed Decoding")
            }
            expectation.fulfill()
        }

        // 3. then
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(itemsList?.page, 1, "It is not equal.")
        XCTAssertEqual(itemsList?.items[0].title, "업로드1", "It is not equal.")
        XCTAssertEqual(itemsList?.items[0].id, 157, "It is not equal.")
        XCTAssertEqual(itemsList?.items[1].id, 163, "It is not equal.")
    }
    
    func testDecodeItem() throws {
        // 1. given
        let url = try URLManager.makeURL(type: .itemId(55))
        var item: Item?
        let expectation = XCTestExpectation(description: "Wait Decoding")

        // 2. when
        APIManager<Item>.handleRequest(object: nil, url: url, httpMethod: .get) { result in
            switch result {
            case .success(let object):
                item = object as? Item
            case .failure(let error):
                print(error)
                XCTFail("Failed Decoding")
            }
            expectation.fulfill()
        }

        // 3. then
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(item?.currency, "USD", "It is not equal.")
        XCTAssertEqual(item?.registrationDate, 1611523563.7406092, "It is not equal.")
        XCTAssertEqual(item?.discountedPrice, 200, "It is not equal.")
    }
    
    func testPostItem() throws {
        // 1. given
        let url = try URLManager.makeURL(type: .registItem)
        let expectation = XCTestExpectation(description: "Wait Posting")
        var resultItem: itemToUpload?

        let yagomImage: UIImage = UIImage(named: "yagom.jpeg")!
        let bearImage: UIImage = UIImage(named: "bear.jpeg")!
        guard let imageData1 = yagomImage.jpegData(compressionQuality: 1),
              let imageData2 = bearImage.jpegData(compressionQuality: 1) else { return }

        let item: itemToUpload = itemToUpload(title: "야곰야곰야곰야곰야곰", descriptions: "야곰야곰야곰야곰야곰야곰을 판매합니다.", price: 1, currency: "KRW", stock: 1, discountedPrice: nil, images: [imageData1, imageData2], password: "0")

        // 2. when
        APIManager<itemToUpload>.handleRequest(object: item, url: url, httpMethod: .post) { result in
            switch result {
            case .success(let data):
                dump(data)
                do {
                    resultItem = try JSONDecoder().decode(itemToUpload.self, from: data as! Data)
                } catch {
                    XCTFail("Failed Decoding")
                }
            case .failure:
                XCTFail("Failed Posting")
            }
            expectation.fulfill()
        }

        // 3. then
        wait(for: [expectation], timeout: 30)
    }
}
