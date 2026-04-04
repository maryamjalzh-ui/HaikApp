//
//  CoachMarksOverlay.swift
//  
//
//  Created by Bayan Alshehri on 15/10/1447 AH.
//

import SwiftUI

// MARK: - Anchor Preference
struct CoachmarkAnchorKey: PreferenceKey {
    static var defaultValue: [CoachmarkTargetID: Anchor<CGRect>] = [:]

    static func reduce(value: inout [CoachmarkTargetID: Anchor<CGRect>],
                       nextValue: () -> [CoachmarkTargetID: Anchor<CGRect>]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// MARK: - View Modifier to attach anchor
extension View {
    func coachmarkTarget(_ id: CoachmarkTargetID) -> some View {
        anchorPreference(key: CoachmarkAnchorKey.self, value: .bounds) { anchor in
            [id: anchor]
        }
    }
}

// MARK: - Overlay
struct CoachMarksOverlay: View {

    @Environment(\.layoutDirection) private var layoutDirection
   
    @ObservedObject var controller: CoachMarksController
    let anchors: [CoachmarkTargetID: Anchor<CGRect>]
    
    private var localizedNext: String {
        String(localized: "coach_next")
    }

    private var localizedDone: String {
        String(localized: "coach_done")
    }

    private let primary = Color(hex: "046048")

    var body: some View {
        GeometryReader { proxy in
            if let step = controller.currentStep,
               let anchor = anchors[step.id] {

                let rawTarget = proxy[anchor]

                let target: CGRect = {
                    switch step.id {
                    case .recommendationButton:
                        // this was the version where step 1 looked correct
                        return rawTarget.offsetBy(dx: 0, dy: proxy.safeAreaInsets.top)

                    case .pinRating:
                        // only a very small correction
                        return rawTarget.offsetBy(dx: 0, dy: 60)

                    case .bottomCard:
                        // only a very small correction
                        return rawTarget.offsetBy(dx: 0, dy: 45)
                    }
                }()

                let padded = target.insetBy(dx: -6, dy: -6)

                ZStack {
                    // Dim background + hole
                    Color.black.opacity(0.68)
                        .mask(
                            HoleMask(frame: padded, shape: step.shape)
                                .compositingGroup()
                        )
                        .ignoresSafeArea()

                    // Tooltip
                    tooltip(step)
                        .position(tooltipPosition(for: padded, in: proxy.size))
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut(duration: 0.25), value: controller.index)
                .contentShape(Rectangle())
                .onTapGesture { } // tapping outside does nothing
            }
        }
        .allowsHitTesting(controller.isActive)
    }

    // MARK: - Tooltip UI (Apple-ish)
    private func tooltip(_ step: CoachmarkStep) -> some View {
        VStack(alignment: layoutDirection == .rightToLeft ? .trailing : .leading, spacing: 10) {
            
            HStack(alignment: .top, spacing: 12) {
                if layoutDirection == .rightToLeft {
                    Button {
                        controller.close()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(width: 34, height: 34)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }

                    Text(step.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)

                } else {
                    Text(step.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        controller.close()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(width: 34, height: 34)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
            }


            Text(step.message)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: layoutDirection == .rightToLeft ? .trailing : .leading)
                .multilineTextAlignment(layoutDirection == .rightToLeft ? .trailing : .leading)
                .environment(\.layoutDirection, layoutDirection)
                .lineLimit(2)

            HStack {
                Text("\(controller.index + 1) / \(controller.steps.count)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                Spacer()

                Button {
                    controller.next()
                } label: {
                    Text(controller.index == controller.steps.count - 1 ? localizedDone : localizedNext)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(width: 290)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: 14, x: 0, y: 8)
    }

    // MARK: - Position
    private func tooltipPosition(for target: CGRect, in size: CGSize) -> CGPoint {
        let w: CGFloat = 290
        let h: CGFloat = 145

        let x = min(max(target.midX, w/2 + 16), size.width - w/2 - 16)

        let below = target.maxY + 16 + h/2
        let above = target.minY - 16 - h/2

        let y: CGFloat
        if below < size.height - 24 {
            y = below
        } else {
            y = max(above, h/2 + 24)
        }
        return CGPoint(x: x, y: y)
    }
    
//    private func correctedFrame(for id: CoachmarkTargetID, rawFrame: CGRect) -> CGRect {
//        switch id {
//        case .recommendationButton:
//            if layoutDirection == .rightToLeft {
//                return rawFrame.offsetBy(dx: -34, dy: 28)
//            } else {
//                return rawFrame.offsetBy(dx: 34, dy: 28)
//            }
//
//        case .pinRating:
//            return rawFrame
//
//        case .bottomCard:
//            return rawFrame
//        }
//    }
}

// MARK: - Hole Mask
private struct HoleMask: View {
    let frame: CGRect
    let shape: CoachmarkShape

    var body: some View {
        Canvas { context, size in
            var path = Path()
            path.addRect(CGRect(origin: .zero, size: size))

            switch shape {
            case .circle:
                let d = max(frame.width, frame.height)
                let circle = CGRect(x: frame.midX - d/2, y: frame.midY - d/2, width: d, height: d)
                path.addEllipse(in: circle)

            case .roundedRect(let r):
                path.addRoundedRect(in: frame, cornerSize: CGSize(width: r, height: r))
            }

            context.fill(path, with: .color(.white), style: FillStyle(eoFill: true))
        }
    }
}

// MARK: - Hex Color Helper
private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
