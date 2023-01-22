//
//  NavigationStack.swift
//  PlayCover
//
//  Created by Amir Mohammadi on 11/2/1401 AP.
//

import SwiftUI

enum StackNavigationTransition: Equatable {
    case none, defaultTranisition, custom(AnyTransition)

    static func == (lhs: StackNavigationTransition, rhs: StackNavigationTransition) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.defaultTranisition, .defaultTranisition):
            return true
        case (.custom, .custom):
            return true
        default:
            return false
        }
    }

    var anyTransition: AnyTransition {
        switch self {
        case .none:
            return AnyTransition.identity
        case .defaultTranisition:
            /// In this case you need to wrap `showingSubview = true` in the
            /// root of the view view in a `withAnimation(.spring()) { ... }`
            return AnyTransition.move(edge: .trailing)
        case .custom(let transition):
            return transition
        }
    }
}

struct StackNavigationView<RootContent>: View where RootContent: View {
    let rootView: RootContent
    let transition: StackNavigationTransition

    @Binding var currentSubview: AnyView
    @Binding var showingSubview: Bool

    init(currentSubview: Binding<AnyView>,
         showingSubview: Binding<Bool>,
         transition: StackNavigationTransition,
         @ViewBuilder rootView: () -> RootContent
    ) {
        self.rootView = rootView()
        self.transition = transition
        self._currentSubview = currentSubview
        self._showingSubview = showingSubview
    }

    var body: some View {
        VStack {
            if !showingSubview {
                rootView
                    .zIndex(-1)
                    .transition(transition == .defaultTranisition
                                ? .move(edge: .leading)
                                : transition.anyTransition)
            } else {
                currentSubview
                    .transition(transition.anyTransition)
                    .zIndex(1)
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button {
                                currentSubview = AnyView(EmptyView())
                                switch transition {
                                case .defaultTranisition:
                                    withAnimation(.spring()) {
                                        showingSubview = false
                                    }
                                default:
                                    showingSubview = false
                                }
                            } label: {
                                Label("BACK", systemImage: "chevron.left")
                            }
                        }
                    }
            }
        }
    }
}
