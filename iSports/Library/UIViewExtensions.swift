//
//  UIViewExtentions.swift
//  
//
//  Created by Susu Liang on 2017/12/13.
//

import UIKit

public extension UIView {

    /**
     A convenience method loads a view from local xib file.
     
     - Author: Roy Hsu
     
     - Parameter nibName: The name of xib file.
     
     - Parameter bundle: The bundle xib file located. Default is nil.
     
     - Returns: The view instance.
     */

    public class func load(nibName name: String, bundle: Bundle? = nil) -> UIView? {

        return UINib.load(nibName: name, bundle: bundle) as? UIView

    }

}
