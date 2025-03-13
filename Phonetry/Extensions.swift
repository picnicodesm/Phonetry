//
//  Extensions.swift
//  Phonetry
//
//  Created by 김상민 on 3/8/24.
//

import Foundation
import UIKit
import SwiftUI


// Apps -> Scenes -> Views

// MARK: - Hide & Show TabBar
extension UIApplication {
    var key: UIWindow? {
        self.connectedScenes
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?
            .windows
            .filter({$0.isKeyWindow})
            .first
    }
}


extension UIView {
    func allSubviews() -> [UIView] {
        var subs = self.subviews
        for subview in self.subviews {
            let rec = subview.allSubviews()
            subs.append(contentsOf: rec)
        }
        return subs
    }
}


struct TabBarModifier {
    static func showTabBar() {
        UIApplication.shared.key?.allSubviews().forEach({ subView in
            if let view = subView as? UITabBar {
                view.isHidden = false
                return
            }
        })
    }
    
    static func hideTabBar() {
        UIApplication.shared.key?.allSubviews().forEach({ subView in
            if let view = subView as? UITabBar {
                view.isHidden = true
                return
            }
        })
    }
}

struct ShowTabBar: ViewModifier {
    func body(content: Content) -> some View {
        return content.padding(.zero).onAppear {
            TabBarModifier.showTabBar()
        }
    }
}
struct HiddenTabBar: ViewModifier {
    func body(content: Content) -> some View {
        return content.padding(.zero).onAppear {
            TabBarModifier.hideTabBar()
        }
    }
}

extension View {
    
    func showTabBar() -> some View {
        return self.modifier(ShowTabBar())
    }
    
    func hiddenTabBar() -> some View {
        return self.modifier(HiddenTabBar())
    }
}


// MARK: - Icon in LargeNavigationTitle
public extension View {
    func navigationBarLargeTitleItems<L>(trailing: L, isShow: Binding<Bool>) -> some View where L : View {
        overlay(NavigationBarLargeTitleItems(trailing: trailing, isShow: isShow).frame(width: 0, height: 0))
    }
}

fileprivate struct NavigationBarLargeTitleItems<L : View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = Wrapper
    
    @Binding var isShow: Bool
    
    private let trailingItems: L
    
    init(trailing: L, isShow: Binding<Bool>) {
        self.trailingItems = trailing
        self._isShow = isShow
    }
    
    func makeUIViewController(context: Context) -> Wrapper {
        Wrapper(representable: self)
    }
    
    func updateUIViewController(_ uiViewController: Wrapper, context: Context) {
        if isShow {
            uiViewController.inputToNavigationView()
            uiViewController.showIcon()
        } else {
            uiViewController.removeFromNavigationView()
        }
    }
    
    class Wrapper: UIViewController {
        private let representable: NavigationBarLargeTitleItems?
        private let controller: UIHostingController<L>?
        
        init(representable: NavigationBarLargeTitleItems) {
            self.representable = representable
            self.controller = UIHostingController(rootView: representable.trailingItems)
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            self.representable = nil
            self.controller = nil
            super.init(coder: coder)
        }
        
        func inputToNavigationView() {
            guard let navigationBar = self.navigationController?.navigationBar else { return }
            guard let UINavigationBarLargeTitleView = NSClassFromString("_UINavigationBarLargeTitleView") else { return }
            guard let controller = controller else { print("controller error!")
                return
            }
            
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            controller.view.backgroundColor = .clear
            
            navigationBar.subviews.forEach { subview in
                if subview.isKind(of: UINavigationBarLargeTitleView.self) {
                    
                    subview.addSubview(controller.view)
                    NSLayoutConstraint.activate([
                        controller.view.centerYAnchor.constraint(equalTo: subview.subviews[0].centerYAnchor),
                        controller.view.trailingAnchor.constraint(
                            equalTo: subview.trailingAnchor,
                            constant: -16
                        )
                    ])
                }
            }
        }
                
        func showIcon() {
            guard let controller = controller else {
                return
            }
            
            UIView.animate(withDuration: 1) {
                controller.view.alpha = 1.0
            }
        }
        
        func removeFromNavigationView() {
            guard let controller = controller else {
                print("controller error!")
                return
            }
            controller.view.alpha = 0
        }
        
        override func viewWillAppear(_ animated: Bool) {
//            super.viewWillAppear(animated)
            inputToNavigationView()
        }
    }
}



// MARK: - Placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
    
    func placeholder(
        _ text: String,
        when shouldShow: Bool,
        alignment: Alignment = .leading) -> some View {
            placeholder(when: shouldShow, alignment: alignment) { Text(text).foregroundColor(.gray) }
        }
}

// MARK: - TextColor
extension Text {
    func remainedDateColor(remain: Int) -> Text {
        if remain <= 3 {
            return self.foregroundColor(.red)
        } else if remain <= 7 {
            return self.foregroundColor(.orange)
        } else {
            return self.foregroundColor(.black)
        }
    }
}


// MARK: - Color
extension Color {
    func toUIColor() -> UIColor {
        let components = self.cgColor?.components
        let red = components?[0] ?? 0
        let green = components?[1] ?? 0
        let blue = components?[2] ?? 0
        let alpha = components?[3] ?? 1
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    func getRGB() -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        let uiColor = self.toUIColor()
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let success = uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        if success {
            return (red, green, blue)
        } else {
            return nil
        }
    }
    
    func getComplementaryColor() -> Color {
        guard let rgb = self.getRGB() else {
            return self
        }
        
        // 255에서 빼야함
        let complementaryRed = 1 - rgb.red
        let complementaryGreen = 1 - rgb.green
        let complementaryBlue = 1 - rgb.blue
        
        return Color(red: complementaryRed, green: complementaryGreen, blue: complementaryGreen)
    }
}
