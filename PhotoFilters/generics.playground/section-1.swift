// Playground - noun: a place where people can play

import UIKit

func doSomething<T> (a: T, b: T) {
    println("hello")
}

doSomething("brad", "brad")

class Stack <T> {
    var items = [T]()
    
    func push (item: T) {
        self.items.append(item)
    }
    
    func pop () -> T {
        var itemToPop = self.items.last
        self.items.removeLast()
        return itemToPop!
    }
}

var myStack = Stack<String>()

myStack.push("Alex")
myStack.push("Stacy's Mom")
myStack.pop()
myStack.items

class Node <T> {
    var value: T?
    var next: Node?
    
    
}

class LinkedList <T> {
    var head: Node<T>?
    
    func insert (value: T) {
        var currentNode = head
        while currentNode?.next != nil {
            currentNode = currentNode?.next
        }
        
        var node = Node<T>()
        node.value = value
        node.next = nil
        
        currentNode?.next = node
    }
}

var node1 = Node<Int>()
node1.value = 100

var node2 = Node<Int>()
node2.value = 200
