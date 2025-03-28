import Quick
import Nimble
import React

@testable import EXDevMenu

class DevMenuAppInstanceTest: QuickSpec {
  class MockedBridge: RCTBridge {
    var enqueueJSCallWasCalled = false

    override func enqueueJSCall(_ moduleDotMethod: String!, args: [Any]!) {
      enqueueJSCallWasCalled = true

      expect(moduleDotMethod).to(equal("RCTDeviceEventEmitter.emit"))
      expect(args.first as? String).to(equal("closeDevMenu"))
    }
  }

  override class func spec() {
    let appInstance = DevMenuAppInstance(
      manager: DevMenuManager.shared
    )
    
    it("checks if `sendCloseEvent` sends correct event") {
      let bridgeDelegate = MockBridgeDelegate()
      let mockedBridge = MockedBridge(delegate: bridgeDelegate, launchOptions: nil)!
      waitBridgeReady(bridgeDelegate: bridgeDelegate)
  
      appInstance.setBridge(mockedBridge)
      appInstance.sendCloseEvent()

      expect(mockedBridge.enqueueJSCallWasCalled).to(beTrue())
    }

    it("checks if js bundle was found") {
      let bridgeDelegate = MockBridgeDelegate()
      let mockedBridge = MockedBridge(delegate: bridgeDelegate, launchOptions: nil)!
      waitBridgeReady(bridgeDelegate: bridgeDelegate)
      
      appInstance.setBridge(mockedBridge)
      let sourceURL = appInstance.sourceURL(for: mockedBridge)

      expect(sourceURL).toNot(beNil())
    }

    it("checks if extra modules was exported") {
      let bridgeDelegate = MockBridgeDelegate()
      let mockedBridge = MockedBridge(delegate: bridgeDelegate, launchOptions: nil)!
      waitBridgeReady(bridgeDelegate: bridgeDelegate)
      appInstance.setBridge(mockedBridge)

      guard let extraModules = appInstance.reactNativeFactory?.rootViewFactory.extraModules(for: mockedBridge) else {
        XCTFail("Failed to call extraModules(for:)")
        return
      }

      expect(extraModules.first { type(of: $0).moduleName() == "DevLoadingView" }).toNot(beNil())
      expect(extraModules.first { type(of: $0).moduleName() == "DevSettings" }).toNot(beNil())
    }
  }
}
