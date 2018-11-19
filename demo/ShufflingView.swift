//
//  ShufflingView.swift
//  demo
//
//  Created by Johan Halin on 19/11/2018.
//  Copyright © 2018 Dekadence. All rights reserved.
//

import UIKit

class ShufflingView: UIView {
    private let containerView = UIView(frame: .zero)
    private let squares: [UIView]
    
    override init(frame: CGRect) {
        var squares = [UIView]()
        
        for _ in 0..<16 {
            let view = UIView(frame: .zero)
            view.backgroundColor = UIColor(white: 0, alpha: 0.5)
            squares.append(view)
            self.containerView.addSubview(view)
        }
        
        self.squares = squares
        
        super.init(frame: frame)

        self.clipsToBounds = false
        
        self.addSubview(self.containerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func adjustViews(toBoard board: Board, animated: Bool) {
        let length = self.bounds.size.width / 4.0 // assume we're square. which we know we are :)
        let containerLength = length * 6.0

        self.containerView.frame = CGRect(
            x: (self.bounds.size.width / 2.0) - (containerLength / 2.0),
            y: (self.bounds.size.height / 2.0) - (containerLength / 2.0),
            width: containerLength,
            height: containerLength
        )

        let block = {
            for (row, rowContents) in board.contents.enumerated() {
                for (column, index) in rowContents.enumerated() {
                    if index == 0 {
                        continue
                    }
                    
                    let view = self.squares[index - 1]
                    view.frame = CGRect(
                        x: (CGFloat(column) * length),
                        y: (CGFloat(row) * length),
                        width: length,
                        height: length
                    )
                }
            }
        }
        
        if (animated) {
            UIView.animate(withDuration: 0.2, animations: block)
        } else {
            block()
        }
    }
}
