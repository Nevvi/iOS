//
//  Popup.swift
//  Nevvi
//
//  Created by Tyler Standal on 2/4/24.
//

import SwiftUI

struct Popup<T: View>: ViewModifier {
    let popup: T
    let isPresented: Bool

    // 1.
    init(isPresented: Bool, @ViewBuilder content: () -> T) {
        self.isPresented = isPresented
        popup = content()
    }

    // 2.
    func body(content: Content) -> some View {
        content
            .overlay(popupContent())
    }

    // 3.
    @ViewBuilder private func popupContent() -> some View {
        GeometryReader { geometry in
            if isPresented {
                popup
                    .animation(Animation.spring(), value: true)
                    .transition(.offset(x: 0, y: geometry.belowScreenEdge))
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

private extension GeometryProxy {
    var belowScreenEdge: CGFloat {
        UIScreen.main.bounds.height - frame(in: .global).minY
    }
}

struct Popup_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
            .previewDevice("iPod touch")
    }
    
    // Helper view that shows a popup
    struct Preview: View {
        @State var isPresented = false
        
        var body: some View {
            ZStack {
                Color.clear
                VStack {
                    Button("Toggle", action: {
                        withAnimation {
                            isPresented.toggle()
                        }
                    })
                    Spacer()
                }
            }
            .modifier(Popup(isPresented: isPresented,
                            content: { Color.yellow.frame(width: 100, height: 100) }))
        }
    }
}
