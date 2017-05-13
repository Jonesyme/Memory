//
//  CustomNavController.swift
//  Memory
//
//
//  Desc: the SOLE purpose of this custom nav controller is to tweak the SizeClass for the main ViewController in order
//        to deliniate an iPad in landscape mode from an iPad in portait mode (a glarring oversight by Apple IMHO).
//        Note: the navbar itself will remain hidden and is otherwise superfluous.
//

import UIKit

class CustomNavController: UINavigationController {
    // override iPad in Landscape to use 'wR hC' SizeClass instead of the 'wR hR' default
    override func overrideTraitCollection(forChildViewController childViewController: UIViewController) -> UITraitCollection? {
        if UI_USER_INTERFACE_IDIOM() == .pad && view.bounds.width > view.bounds.height {
            let collections = [UITraitCollection(horizontalSizeClass: .regular), UITraitCollection(verticalSizeClass: .compact)]
            return UITraitCollection(traitsFrom: collections)
        }
        return super.overrideTraitCollection(forChildViewController: childViewController)
    }
}
