//
//  ImaginariumUITests.swift
//  ImaginariumUITests
//
//  Created by Konstantin Penzin on 13.08.2023.
//

import XCTest

final class ImaginariumUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("koverboard@icloud.com")
        webView.swipeUp()
        dismissKeyboardIfPresent()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("KTJ_xtf2yxc2bwd@tdj")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        app.swipeUp()
        sleep(2)
        
        app.swipeDown()
        sleep(2)
        
        let cellToManage = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        let likeButton = cellToManage.children(matching: .button).element
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        likeButton.tap()
        sleep(2)
        likeButton.tap()
        
        sleep(2)
        
        cellToManage.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        
        image.pinch(withScale: 3, velocity: 1)
        
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButton = app.buttons["nav back button"]
        navBackButton.tap()
        
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
           
        XCTAssertTrue(app.staticTexts["Konstantin Penzin"].exists)
        XCTAssertTrue(app.staticTexts["@koverboard"].exists)
            
        app.buttons["logout button"].tap()
            
        app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Yes"].tap()
        sleep(2)
    }
    
    func dismissKeyboardIfPresent() {
        if app.keyboards.element(boundBy: 0).exists {
            if UIDevice.current.userInterfaceIdiom == .pad {
                app.keyboards.buttons["Hide keyboard"].tap()
            } else {
                app.toolbars.buttons["Done"].tap()
            }
        }
    }
}
