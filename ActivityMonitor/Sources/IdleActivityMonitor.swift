//
//  IdleActivityMonitor.swift
//  ActivityMonitor
//
//  Created by Phanith on 10/9/21.
//

import UIKit

final class IdleActivityMonitor {
  
  enum State {
    case running
    case paused
  }
  
  typealias Callback = (() -> Swift.Void)
  
  // MARK: - Properties
  
  private static let shared = IdleActivityMonitor()
  
  // Use this parameter to calculate when and after user back from background
  private var backgroundedDate: Date = .init()
  
  // Our callback when timeout
  private var callback: Callback?
  
  // Our current clock, kick start when timer fire
  private var seconds: Int = 0 {
    didSet {
      if seconds >= timeout {
        IdleActivityMonitor.stopMonitoring()
        DispatchQueue.main.async {
          self.callback?()
        }
      }
    }
  }
  
  // Represent timer state if it is running or paused
  private var state: State = .paused
  
  // Represent time out in second.
  private var timeout: Int {
    #warning("Update your timeout in second here")
    return 10
  }
  
  // Out clock tick
  private var timer: BackgroundTimer?
  
  private init() {}
  
  // MARK: - Instance methods
  
  static func onTimeout(_ callback: Callback?) {
    shared.callback = callback
  }
  
  static func startMonitoring() {
    shared.fireTimer()
  }
  
  static func stopMonitoring() {
    shared.stopTimer()
  }
  
  static func reset() {
    shared.seconds = 0
    if shared.state == .paused {
      startMonitoring()
    }
  }
  
  // MARK: - Actions
  
  // ONLY fire timer and add observer if and only if timer not yet allocated.
  private func fireTimer() {
    if timer == nil {
      timer = .init(timeInterval: 1.0)
      timer?.eventHandler = { [weak self] in
        guard let self = self else {
          return
        }
        self.seconds += 1
      }
      timer?.resume()
      state = .running
      addObservers()
    }
  }
  
  /**
    -> We reset clock tick
    -> Mark our background timer as suspend and nil it
    -> Remove observer, make sure we don't add the same observers every time SDK open.
   */
  private func stopTimer() {
    seconds = 0
    timer?.suspend()
    timer = nil
    state = .paused
    removeObservers()
  }
  
  // MARK: - Observers
  
  private func addObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
  }
  
  private func removeObservers() {
    NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
  }
  
  // Save timeInterval when move to background
  @objc
  private func didEnterBackground(_ notification: Notification) {
    backgroundedDate = Date()
  }
  
  // Calculate timeInterval since moved to background
  @objc
  private func didBecomeActive(_ notification: Notification) {
    let currentDate = Date()
    let secondsFromBackgrounded = currentDate.timeIntervalSinceNow - backgroundedDate.timeIntervalSinceNow
    seconds += Int(secondsFromBackgrounded)
  }
  
  @objc
  private func resetIdleTimer() {
    IdleActivityMonitor.reset()
  }
}

extension NSNotification.Name {
    public static let TimeOutUserInteraction: NSNotification.Name = NSNotification.Name(rawValue: "TimeOutUserInteraction")
}

enum TimeOut: Int {
    case after30 = 30
    case after60 = 60
    case after180 = 180
}

extension UIWindow {
  open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    IdleActivityMonitor.reset()
    return super.hitTest(point, with: event)
  }
}
