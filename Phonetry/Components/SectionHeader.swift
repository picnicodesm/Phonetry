//
//  SectionHeader.swift
//  Phonetry
//
//  Created by 김상민 on 2/20/24.
//

import SwiftUI

// **********************   DEPRECATED   *******************
struct SectionHeader: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: GlobalConstants.FontSize.sectionHeader))
            .fontWeight(.semibold)
            .padding(.top, GlobalConstants.sectionPadding)
    }
}
