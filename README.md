

# Open Market

API 문서를 토대로 서버와 통신하여 상품을 등록, 수정, 삭제할 수 있는 오픈마켓 프로젝트

- 프로젝트 진행 기간: 2021.01.25 ~ 2021.02.05
- 팀 프로젝트: 꼬말, 오동나무
- 구현 키워드: HTTP, JSON, Swift, URLSession, UnitTest  

<br>

# 구현한 기능

### 1.

서버의 API와 통신할 수 있도록 Model 타입 구현

![Untitled](https://user-images.githubusercontent.com/73867548/121780967-a3b9b600-cbdd-11eb-9a8c-2f8b6f57ca4f.png)

<br>

### 2.

URLSession을 활용하여 상품을 관리하는 get, post, patch, delete 기능 구현

![Untitled 1](https://user-images.githubusercontent.com/73867548/121780968-a5837980-cbdd-11eb-89ad-a755493a188f.png)

![Untitled 2](https://user-images.githubusercontent.com/73867548/121780970-a61c1000-cbdd-11eb-8d94-65ad54520294.png)

<br>

### 3.

네트워크 통신 기능에 대한 단위 테스트(Unit Test)

![Untitled 3](https://user-images.githubusercontent.com/73867548/121780973-a74d3d00-cbdd-11eb-9ed4-e9c510522d86.png)

❗️❗️❗️ 코드 구조를 전체적으로 변경한 후에는 서버의 문제로 테스트 코드를 작성하지 못한 상태입니다. 기존에 작성했던 테스트 코드는 `step1-test` 브랜치에서 확인이 가능합니다.

<br>

# 주요 고민 포인트

## 🤔 URLSession을 처리하는 구조에 대한 고민

 URLSession에 대한 코드를 작성하다보니 HTTPMethod, Reqeust, body, URL 등 필요한 요소들은 많아지는 반면에 교묘하게 (내용상 비슷하지만 코드가 다른) 중복되는 코드들이 많아지게 되었습니다. <br>

(UML은 URLSession 파트만 작성해보았습니다.) <br>

**<처음 작성했던 코드 UML>**

![Untitled 4](https://user-images.githubusercontent.com/73867548/121780975-a7e5d380-cbdd-11eb-83c0-8939b7d5a821.png)

- URL, Data, 등을 메서드 외부에서 만들어서 파라미터로 전달해야 하는 불편함이 있었습니다.
- 전체적으로 비슷한데 내부의 코드가 조금씩 다른 메서드들의 코드 중복 문제를 해결하지 못하였습니다.
- Parser라는 객체 네이밍도 적절하지 않은 것 같았습니다.

이 구조를 아래와 같이 수정해보았습니다. 

<br>

**<수정한 코드 구조 UML>**

![Untitled 5](https://user-images.githubusercontent.com/73867548/121780977-a9170080-cbdd-11eb-9ee4-d63dc2355ad0.png)


- 열거형을 활용하여 원하는 case만 작성해주면 URL과 HTTPMethod를 가지게 됩니다.
- 열거형을 통해 중복되는 코드를 없애고 하나의 메서드에 파라미터로 RequestType만 전달하면 동작할 수 있도록 수정해보았습니다.
- APIManager 내부에 private 메서드를 만들어 API 객체 내부에서 URLSession 관련 요청을 모두 해결해줄 수 있습니다.

<br>

## 🤔 비동기로 처리되는 테스트 코드

 비동기 메서드를 테스트하기 위해서는 비동기로 처리되는 작업을 기다려주어야 했습니다.

```swift
func testDecodeItem() throws {
        // 1. given
        let url = try URLManager.makeURL(type: .itemId(55))
        var item: Item?
        let expectation = XCTestExpectation(description: "Wait Decoding")

        // 2. when
        Parser<Item>.decodeData(url: url) { result in
            switch result {
            case .success(let object):
                item = object
            case .failure:
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

```

- XCTestExpectation을 만들어주고 fulfill 메서드로 작업이 끝났음을 알려줍니다. 그리고 wait(for:timeout:) 메서드로 expectation을 기다려줄 수 있었습니다.
- wait 메서드에서는 제한시간을 설정하여 실행할 수 있는데 이때 테스트 메서드가 시간내에 작업을 완료하지 못해서 테스트에서 실패하는 경우도 있었습니다.

<br>

## 🤔 이미지 업로드하기 (Content-Type: multipart/data-form)

 이미지와 JSON을 함께 서버에 보내는 방법에 대해 고민하게 되었습니다. 이 코드를 좀 더 이해하기 위해서 HTTP 요청 메세지의 헤더와 multipart/data-form 이라는 MIMEType에 대해서 이해가 필요했습니다. <br>

 JSON 데이터와 이미지를 함께 업로드하기 위해서는 `URLRequest.httpBody`에 **JSON 데이터 + 이미지 데이터** 를 이어붙여서 요청을 보낼 수 있었습니다. <br>

당시 공부하며 작성했던 블로그 링크입니다.

- [HTTP 이해하기, (+ HTTPS)](https://odong-tree.github.io/cs/2021/01/18/http/)    

- [URLRequest의 setValue, Content-Type](https://odong-tree.github.io/ios/2021/01/30/urlrequest_mimetype/)      

- [URLSession 이미지 업로드하기, multipart/data-form](https://odong-tree.github.io/ios/2021/02/03/multipart_data-form/)    

<br>

# 프로젝트 회고
- 작성한 코드가 마음에 들지않아 썼다 지웠다를 여러번 반복했던 프로젝트였습니다. 코드의 구조에 대한 고민은 생소했기에 많은 시간을 투자해야했고 코드를 자주 갈아엎는 경험도 했었습니다.
- 시간은 오래 걸렸음에도 원하는 결과를 만들어내어 뿌듯하지만 더 많은 기능을 접해보지 않고 고집을 부렸던 것이 아쉽기도 합니다.
- 분명 유익한 시간들이었습니다만 더 좋은 코드를 쓰겠다는 좁은 생각에 매몰되어서는 안되겠다는 생각을 하게 되었습니다.

<br>


