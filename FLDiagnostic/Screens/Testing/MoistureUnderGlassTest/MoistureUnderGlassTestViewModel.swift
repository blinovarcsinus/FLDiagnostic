//
//  MoistureUnderGlassTestViewModel.swift
//  Forward Leasing
//
//  Created by Kirirushi on 24.12.2019.
//  Copyright © 2019 Arcsinus. All rights reserved.
//

class MoistureUnderGlassTestViewModel: BaseControllerViewModel {
  var test: Test
  var page: Int

  init(_ test: Test, page: Int) {
    self.test = test
    self.page = page
    super.init()
  }

  func testFailed() {
    test.isPassed = false
    abortDiagnostik()
  }

  func startNextTest() {
    test.timeSpent = DiagnosticService.shared.calculateSpentTime()
    test.isPassed = true
    showNextTestViewController()
  }
}
