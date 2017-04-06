//
//  UITableView+Extensions.swift
//  Dart Scorer
//
//  Created by Michael Du Plessis on 2017-04-05.
//  Copyright © 2017 Michael Du Plessis. All rights reserved.
//

import UIKit

extension UITableView {
    
    // This trick will hide the empty cells that you see at the end of the last
    // item in a "plain" style UITableView.
    func hideEmptyRows() {
        self.tableFooterView = UIView()
    }
    
}
