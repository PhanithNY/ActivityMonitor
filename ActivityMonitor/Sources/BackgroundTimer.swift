//
//  BackgroundTimer.swift
//  ActivityMonitor
//
//  Created by Phanith on 10/9/21.
//

import Foundation

final class BackgroundTimer {
  
  var eventHandler: (() -> Swift.Void)?
  
  // MARK: - Properties
  
  private enum TimerState {
    case suspended
    case resumed
  }
  
  private let timeInterval: TimeInterval
  
  private var state: TimerState = .suspended
  
  private lazy var timer: DispatchSourceTimer = {
    let t = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
    t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
    t.setEventHandler(handler: { [weak self] in
      self?.eventHandler?()
    })
    return t
  }()
  
  // MARK: - Init / Deinit
  
  init(timeInterval: TimeInterval) {
    self.timeInterval = timeInterval
  }
  
  deinit {
    timer.setEventHandler {}
    timer.cancel()
    /*
     If the timer is suspended, calling cancel without resuming
     triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
     */
    resume()
    eventHandler = nil
  }
  
  // MARK: - Actions
  
  final func resume() {
    if state == .resumed {
      return
    }
    state = .resumed
    timer.resume()
  }
  
  final func suspend() {
    if state == .suspended {
      return
    }
    state = .suspended
    timer.suspend()
  }
  
}
