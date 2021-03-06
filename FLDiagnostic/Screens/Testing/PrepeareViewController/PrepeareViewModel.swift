//
//  PrepeareViewModel.swift
//  Forward Leasing
//
//  Created by Данил on 19/12/2019.
//  Copyright © 2019 Arcsinus. All rights reserved.
//

import RxSwift

class PrepeareControllerViewModel: BaseControllerViewModel {
  var serverText = BehaviorSubject<String>(value: "Подключение к серверу")
  var modelText = BehaviorSubject<String>(value: "Проверка модели")
  
  var serverImage = BehaviorSubject<UIImage>(value: UIImage.FLImage("ic_checkbox_gray"))
  var modelImage = BehaviorSubject<UIImage>(value: UIImage.FLImage("ic_checkbox_gray"))
  
  var nextButtonHidden = BehaviorSubject<Bool>(value: true)
  var nextButtonColor = BehaviorSubject<UIColor>(value: #colorLiteral(red: 1, green: 0.4918404222, blue: 0.2512650192, alpha: 1))
  var nextButtonText = BehaviorSubject<String>(value: "Начать тестирование")
  var nextButtonTitleColor = BehaviorSubject<UIColor>(value: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
  
  var nextButtonPressed = PublishSubject<Void>()
  
  private var successConnection = false
  private var disposeBag = DisposeBag()
  
  override func setupModel() {
    super.setupModel()
    
    modelText.onNext("Проверка модели")
    
    startDiagnosticSession()
    
    nextButtonPressed.asObserver().subscribe(onNext: { [unowned self] () in
      if self.successConnection {
        self.showNextTestViewController()
      } else {
        self.startDiagnosticSession()
      }
    }).disposed(by: disposeBag)
  }
  
  private func startDiagnosticSession() {
    serverText.onNext("Подключаемся к серверу...")
    serverImage.onNext(UIImage.FLImage("LoaderImage"))
    
    APIService.shared.getDiagnostics().subscribe(onNext: { (result) in
     switch result {
      case .success(let response):
        self.patchDevice()
      case .failure(let _):
        self.patchDevice()
     }
    }).disposed(by: disposeBag)
  }

  private func showColorPickController() {
    let viewModel = DeviceColorViewModel()
    guard let viewController = DeviceColorViewController.create(viewModel) else { return }
    showViewController.onNext(viewController)
  }

  private func getActiveSesion() {
    APIService.shared.getDiagnostics().subscribe(onNext: { (result) in
      switch result {
       case .success(let response):
        DiagnosticService.shared.setCurrentDiagnostikSesion(response.diagnostic)
        self.setSuccessForConnection()
				self.setModelScheckSuccess()
				self.setNextButtonAvailabel()
       case .failure(let error):
				if error == .invalidModel {
					self.setModelCheckError()
					self.setSuccessForConnection()
				} else {
					self.setErrorForConnection()
				}
      }
    }).disposed(by: disposeBag)
  }
  
  private func patchDevice() {
    APIService.shared.pathDevice().subscribe(onNext: { (response) in
      switch response {
      case .success(let _):
        self.getActiveSesion()
      case .failure(let error):
				if error == .invalidModel {
					self.setModelCheckError()
					self.setSuccessForConnection()
				} else {
					self.setErrorForConnection()
				}
      }
    }).disposed(by: disposeBag)
  }
  
  private func setErrorForConnection() {
    serverText.onNext("Ошибка подключения к серверу")
    serverImage.onNext(UIImage.FLImage("TestError"))
    
    nextButtonHidden.onNext(false)
    nextButtonColor.onNext(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
    nextButtonText.onNext("Повторить попытку")
    nextButtonTitleColor.onNext(#colorLiteral(red: 1, green: 0.4918404222, blue: 0.2512650192, alpha: 1))
  }
  
  private func setSuccessForConnection() {
    self.successConnection = true
    serverText.onNext("Подключение установлено")
    serverImage.onNext(UIImage.FLImage("TestComplete"))
  }
	
	private func setNextButtonAvailabel() {
		nextButtonHidden.onNext(false)
		nextButtonColor.onNext(#colorLiteral(red: 1, green: 0.4918404222, blue: 0.2512650192, alpha: 1))
		nextButtonText.onNext("Начать тестирование")
		nextButtonTitleColor.onNext(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
	}
	
	private func setModelScheckSuccess() {
		let deviceString = DeviceService.deviceModel + " " + "(\(DeviceService.diskSpaceGB))"
		modelText.onNext(deviceString)
		modelImage.onNext(UIImage.FLImage("TestComplete"))
	}
	
	private func setModelCheckError() {
		modelText.onNext("Ошибка при проверке модели")
		modelImage.onNext(UIImage.FLImage("TestError"))
	}

}
