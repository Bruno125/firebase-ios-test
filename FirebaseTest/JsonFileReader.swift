//
//  JsonFileReader.swift
//  FandangoLatam
//
//  Created by Bruno Aybar on 19/02/2017.
//  Copyright © 2017 FandangoLatam. All rights reserved.
//

import Foundation

class JsonFileReader{
    
    static func read(file: String) -> String{
        let klass : AnyClass = self
        guard let pathString = Bundle(for: klass).path(forResource: file, ofType: "json") else {
            fatalError("UnitTestData.json not found")
        }
        
        guard let jsonString = try? NSString(contentsOfFile: pathString, encoding: String.Encoding.utf8.rawValue) as String else {
            fatalError("Unable to convert UnitTestData.json to String")
        }
        
        return jsonString
    }
}
