//
//  TestWiFiViewModel.swift
//  Forward Leasing
//
//  Created by Данил on 20/12/2019.
//  Copyright © 2019 Arcsinus. All rights reserved.
//

import RxSwift
import Reachability

class TestWifiViewModel: BaseControllerViewModel {
  var test: Test
  var page: Int
  
  init(_ test: Test, page: Int) {
    self.test = test
    self.page = page
    super.init()
  }
  
  var notWorkingHidden = BehaviorSubject<Bool>(value: false)
  var retryHidden = BehaviorSubject<Bool>(value: false)
  
  var infoImage = BehaviorSubject<UIImage>(value: UIImage.FLImage("ic_wifi_off_grey"))
  var infoText = BehaviorSubject<String>(value: "Не подключен")
  var infoTextColor = BehaviorSubject<UIColor>(value: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0))
  var titleText = BehaviorSubject<String>(value: "")
  
  var notWorkingButtonPressed = PublishSubject<Void>()
  var retryButtonPressed = PublishSubject<Void>()
  var isProgressing = BehaviorSubject<Bool>(value: false)
  
  private var isSucceed: Bool = false
  private var disposeBag = DisposeBag()
  
  override func setupModel() {
    super.setupModel()
    
    notWorkingButtonPressed.asObserver().subscribe(onNext: { [unowned self] () in
      self.isSucceed = true
      
      self.test.isPassed = false
      self.notWorkingDiagnostic(self.test)
    }).disposed(by: disposeBag)
    
    retryButtonPressed.asObserver().subscribe(onNext: { [unowned self] () in
      self.startSeachingWifi()
    }).disposed(by: disposeBag)
    
    startSeachingWifi()
  }
  
  func startSeachingWifi() {
    self.isSucceed = false

    notWorkingHidden.onNext(true)
    retryHidden.onNext(true)
    infoText.onNext("Поиск сетей Wi-Fi...")
    infoTextColor.onNext(#colorLiteral(red: 0.09411764706, green: 0.03529411765, blue: 0.3215686275, alpha: 1))
    
    isProgressing.onNext(true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      NetworkManager.isReachableViaWiFi { [unowned self] (connected) in
        self.isProgressing.onNext(false)
        
        if self.isSucceed == true { return }
        
        if connected {
          self.setTestSucceed()
        } else {
          self.setTestError()
        }
      }
    }
  }
  
  
  private func setTestSucceed() {
    isSucceed = true
    titleText.onNext("")
    infoTextColor.onNext(#colorLiteral(red: 0, green: 0.7529411765, blue: 0.1882352941, alpha: 1))
    infoText.onNext("Тест успешно пройден")
    infoImage.onNext(UIImage.FLImage("TestComplete"))
    
    retryHidden.onNext(true)
    notWorkingHidden.onNext(true)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      self.test.timeSpent = DiagnosticService.shared.calculateSpentTime()
      self.test.isPassed = true
      self.showNextTestViewController()
    }
  }
  
  private func setTestError() {
    titleText.onNext("")
    infoTextColor.onNext(#colorLiteral(red: 0.9176470588, green: 0, blue: 0, alpha: 1))
    infoText.onNext("Не подключены к сети Wi-Fi\nПодключитесь к любой сети Wi-Fi\n")
    infoImage.onNext(UIImage.FLImage("TestError"))
    
    retryHidden.onNext(false)
    notWorkingHidden.onNext(false)
  }
}

struct WifiInfo {
    public let interface: String
    public let ssid: String
    public let bssid: String
    init(_ interface: String, _ ssid: String,_ bssid: String) {
        self.interface = interface
        self.ssid = ssid
        self.bssid = bssid
    }
}
