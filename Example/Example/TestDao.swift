//
//  testDao.swift
//  Example
//
//  Created by lidaye on 22/06/2017.
//  Copyright © 2017 Softlab. All rights reserved.
//

import CoreData

class TestDao: DaoTemplate {

    func saveWithContent(_ content: String) -> Test {
        let test = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(Test.self),
                                                       into: context) as? Test
        test?.content = content
        self.saveContext()
        return test!
    }
    
}
