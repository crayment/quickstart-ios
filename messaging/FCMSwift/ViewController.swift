//
//  Copyright (c) 2016 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@objc(ViewController)
class ViewController: UIViewController {

  let testSubscriptionCount = 500

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  @IBAction func handleLogTokenTouch(sender: UIButton) {
    // [START get_iid_token]
    let token = FIRInstanceID.instanceID().token()
    print("InstanceID token: \(token!)")
    // [END get_iid_token]
  }

  @IBAction func handleNotificationToggleAtOnce(sender: UISwitch) {
    if sender.on {
      for i in 1..<testSubscriptionCount {
        FIRMessaging.messaging().subscribeToTopic("/topics/news\(i)")
      }
      print("Subscribed to notifications")
    } else {
      for i in 1..<testSubscriptionCount {
        FIRMessaging.messaging().unsubscribeFromTopic("/topics/news\(i)")
      }
      print("Unsubscribed from notifications")
    }
  }

  @IBAction func handleNotificationToggleSeriallyOnMainThread(sender: UISwitch) {
    if sender.on {
      var previousOperation: NSOperation? = nil
      for i in 1..<testSubscriptionCount {
        let operation = NSBlockOperation() { FIRMessaging.messaging().subscribeToTopic("/topics/news\(i)") }
        operation.queuePriority = .Low
        if let previous = previousOperation {
          operation.addDependency(previous)
        }
        NSOperationQueue.mainQueue().addOperation(operation)
        previousOperation = operation
      }
      print("Subscribed to notifications")
    } else {
      var previousOperation: NSOperation? = nil
      for i in 1..<testSubscriptionCount {
        let operation = NSBlockOperation() { FIRMessaging.messaging().unsubscribeFromTopic("/topics/news\(i)") }
        operation.queuePriority = .Low
        if let previous = previousOperation {
          operation.addDependency(previous)
        }
        NSOperationQueue.mainQueue().addOperation(operation)
        previousOperation = operation
      }
      print("Unsubscribed from notifications")
    }
  }

  let queue: NSOperationQueue = {
    let queue = NSOperationQueue()
    queue.qualityOfService = .Background
    return queue
  }()

  @IBAction func handleNotificationToggleSeriallyOnBackgroundThread(sender: UISwitch) {
    if sender.on {
      var previousOperation: NSOperation? = nil
      for i in 1..<100 {
        let operation = NSBlockOperation() { FIRMessaging.messaging().subscribeToTopic("/topics/news\(i)") }
        operation.queuePriority = .Low
        if let previous = previousOperation {
          operation.addDependency(previous)
        }
        queue.addOperation(operation)
        previousOperation = operation
      }
      print("Subscribed to notifications")
    } else {
      var previousOperation: NSOperation? = nil
      for i in 1..<100 {
        let operation = NSBlockOperation() { FIRMessaging.messaging().unsubscribeFromTopic("/topics/news\(i)") }
        operation.queuePriority = .Low
        if let previous = previousOperation {
          operation.addDependency(previous)
        }
        queue.addOperation(operation)
        previousOperation = operation
      }
      print("Unsubscribed from notifications")
    }
  }

  @IBAction func handleSubscribeTouch(sender: UIButton) {
    // [START subscribe_topic]
    FIRMessaging.messaging().subscribeToTopic("/topics/news")
    print("Subscribed to news topic")
    // [END subscribe_topic]
  }

}
