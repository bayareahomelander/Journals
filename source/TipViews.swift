//
//  SearchTipView.swift
//  Journals
//
//  Created by Paco Sun on 2023-09-15.
//

import Foundation
import SwiftUI
import TipKit

struct SearchTipView: Tip {
    var title: Text {
        Text("Search by Dates or Content")
            .font(.system(size: 15))
            .fontWeight(.semibold)
    }
    
    var message: Text? {
        Text("Find your past journals here. For dates, simply enter the month/day number, or full date if needed.")
            .font(.system(size: 12))
    }
}

struct arrowTipView: Tip {
    var title: Text {
        Text("Quickly Navigate Through Dates")
            .font(.system(size: 15))
            .fontWeight(.bold)
    }
    
    var message: Text? {
        Text("Tap the arrows to jump 3 days backward or forward for quick navigation.")
            .font(.system(size: 12))
    }
}

struct filterTipView: Tip {
    var title: Text {
        Text("Navigate Event List with Buttons")
            .font(.system(size: 15))
            .fontWeight(.semibold)
    }
    
    var message: Text? {
        Text("Filter your events by tag or pin status, or search for an event by title or tag.")
            .font(.system(size: 12))
    }
}

struct savePictureView: Tip {
    var title: Text {
        Text("Save as Picture")
            .font(.system(size: 15))
            .fontWeight(.semibold)
    }
    
    var message: Text? {
        Text("Click the icon to save your event as a screenshot and share later.")
            .font(.system(size: 12))
    }
}
