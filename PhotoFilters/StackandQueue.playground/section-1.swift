// Playground - noun: a place where people can play

import UIKit

class Queue {
    
    var queueArray = [String]()
    
    func enqueue(stringToEnqueue : String) {
        self.queueArray.append(stringToEnqueue)
    }
    
    func dequeue() -> String? {
        if !queueArray.isEmpty {
            var dequeuedString = queueArray.first
            queueArray.removeAtIndex(0)
            return dequeuedString!
        } else {
            return nil
        }
    }
}

class Stack {
    
    var stackArray = [String]()
    
    func push (stringToPush : String) {
        self.stackArray.append(stringToPush)
    }
    
    func pop() ->String? {
        if !self.stackArray.isEmpty {
            var stringToReturn = self.stackArray.last
            self.stackArray.removeLast()
            return stringToReturn!
        } else {
            return nil
        }
    }
}

var myStack = Stack()

myStack.push("Stacy")
myStack.push("Person1")
var top = myStack.pop()