//
//  Wine.swift
//  My Grape Vine
//
//  Created by Daniel Martin (RIT Student) on 5/15/17.
//  Copyright © 2017 Daniel Martin (RIT Student). All rights reserved.
//

import Foundation

class Wine{
    var name:String
    var state:String?
    var rating:String?
    
    init(name:String, state:String?, rating:Float?){
        self.name = name
        self.rating = "\(rating)"
    }
}
