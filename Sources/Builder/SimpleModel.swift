//
//  SimpleModel.swift
//

import Foundation
import SwiftData

@Model
public class SimpleModel {
    @Attribute(.unique) public var id:Int64
    public var name:String
    
    init(id: Int64, name: String) {
        self.id = id
        self.name = name
    }
}
