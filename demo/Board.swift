//
//  Board.swift
//  demo
//
//  Created by Johan Halin on 19/11/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

struct Board {
    let contents: [[Int]]
    
    private init(contents: [[Int]]) {
        var count = 0
        
        for row in contents {
            for value in row {
                if value > 0 {
                    count += 1
                }
            }
        }
        
        if count != 16 {
            fatalError("invalid amount of values: \(count). should be 16")
        }
        
        self.contents = contents
    }
    
    static func initialBoard() -> Board {
        return Board(contents:
            [
                [0, 0, 0, 0, 0, 0],
                [0, 1, 2, 3, 4, 0],
                [0, 5, 6, 7, 8, 0],
                [0, 9, 10,11,12,0],
                [0, 13,14,15,16,0],
                [0, 0, 0, 0, 0, 0]
                ]
        )
    }
}
