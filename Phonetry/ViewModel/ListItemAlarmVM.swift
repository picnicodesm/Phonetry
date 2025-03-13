//
//  ListItemAlarmVM.swift
//  Phonetry
//
//  Created by 김상민 on 5/18/24.
//

import Foundation

class ListItemAlarmVM: ObservableObject {
    @Published var alarmPresented: Bool = false
}

/*
 LazyVStack 안에서 Item들을 로드하면서 alarm을 사용함에 버그 발생(새로 로드되는 아이템이서 alarm이 작동하지 않음)
 ViewModel을 통해 각각의 아이템에 대한 alarm 관리변수를 Item 내부가 아닌 외부에 따로 만들어 줌으로써 StateObject를 통해 관리
 각 ListItem이 독립적인 StateObject를 가지고 이를 통해 상태를 관리함.
 lazy에서 @State를 사용하면 
 */
