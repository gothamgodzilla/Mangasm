import SwiftUI

// MARK: - LandmarkSlides

/// Cross-fading 4-city landmark slideshow background.
///
/// - Cycle: 4.2 s per slide, 1.4 s cross-fade.
/// - Each slide: sky LinearGradient (180°, stops 0%/56%/100%) + sun-haze radial
///   + `Skyline` filled `MGColor.skylineInk` + reflective ground band.
/// - Ken-Burns: scale 1.02 → 1.16 over ~9 s per slide, pan toward (60%, 40%).
/// - Caption: coordinates mono / city name serif / italic tag.
/// - Progress dots: active = 18 px gold pill w/ glow; inactive = 6 px dim.
public struct LandmarkSlides: View {
    @State private var index: Int = 0
    @State private var dotIndex: Int = 0   // lags index by fade duration so dots flip at cross-fade start
    @State private var isActive: Bool = true

    private let cycleDuration: Double = 4.2
    private let fadeDuration: Double = 1.4

    public init() {}

    public var body: some View {
        ZStack {
            // Slide layers (all present, opacity cross-fades)
            ForEach(Array(City.allCases.enumerated()), id: \.offset) { i, city in
                SlideLayer(city: city, isActive: i == index)
            }

            // Top veil
            LinearGradient(
                stops: [
                    .init(color: Color(red: 6/255, green: 4/255, blue: 9/255).opacity(0.55), location: 0),
                    .init(color: Color(red: 6/255, green: 4/255, blue: 9/255).opacity(0.12), location: 0.26),
                    .init(color: Color(red: 6/255, green: 4/255, blue: 9/255).opacity(0.30), location: 0.56),
                    .init(color: Color(red: 4/255, green: 3/255, blue: 7/255).opacity(0.94), location: 1),
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Vignette
            Rectangle()
                .fill(.black.opacity(0.38))
                .blur(radius: 40)
                .padding(-20)
                .allowsHitTesting(false)

            // Caption + dots
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 92)

                CaptionBlock(city: City.allCases[dotIndex])

                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<City.allCases.count, id: \.self) { i in
                        Capsule()
                            .fill(i == dotIndex ? MGColor.gold : Color.white.opacity(0.34))
                            .frame(width: i == dotIndex ? 18 : 6, height: 6)
                            .shadow(color: i == dotIndex ? MGColor.gold.opacity(0.7) : .clear, radius: 4)
                            .animation(.easeInOut(duration: 0.4), value: dotIndex)
                    }
                }
                .padding(.top, 16)

                Spacer()
            }
        }
        .onAppear {
            startCycle()
        }
        .onDisappear {
            isActive = false
        }
    }

    private func startCycle() {
        // Repeating timer every cycleDuration seconds
        // Use a recursive dispatch to avoid Timer issues with Swift 6 sendability
        scheduleNext()
    }

    private func scheduleNext() {
        DispatchQueue.main.asyncAfter(deadline: .now() + cycleDuration) {
            guard isActive else { return }
            let next = (index + 1) % City.allCases.count
            withAnimation(.easeInOut(duration: fadeDuration)) {
                index = next
            }
            // Update dots at start of cross-fade
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    dotIndex = next
                }
            }
            scheduleNext()
        }
    }
}

// MARK: - SlideLayer

private struct SlideLayer: View {
    let city: City
    let isActive: Bool

    @State private var kenBurnsScale: CGFloat = 1.02

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Sky gradient
                LinearGradient(
                    stops: [
                        .init(color: city.sky[0], location: 0),
                        .init(color: city.sky[1], location: 0.56),
                        .init(color: city.sky[2], location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Sun haze radial at ~(62%, 44%)
                RadialGradient(
                    colors: [
                        city.sky[2].opacity(0.8),
                        city.sky[2].opacity(0.13),
                        .clear,
                    ],
                    center: UnitPoint(x: 0.62, y: 0.44),
                    startRadius: 0,
                    endRadius: geo.size.width * 0.4
                )
                .blendMode(.screen)
                .blur(radius: 6)
                .ignoresSafeArea()

                // Skyline silhouette
                Skyline(city: city)
                    .fill(MGColor.skylineInk.opacity(0.9))
                    .shadow(color: MGColor.skylineInk.opacity(0.5), radius: 14, x: 0, y: -2)
                    .frame(height: geo.size.height * 0.4)
                    .offset(y: -geo.size.height * 0.4)  // position above the bottom 40%

                // Reflective ground band (bottom 40%)
                LinearGradient(
                    colors: [city.sky[2].opacity(0.4), Color(red: 6/255, green: 3/255, blue: 8/255)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: geo.size.height * 0.4)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            // Ken-Burns transform
            .scaleEffect(kenBurnsScale, anchor: UnitPoint(x: 0.6, y: 0.4))
            .animation(
                isActive ? .linear(duration: 9).repeatForever(autoreverses: false) : .linear(duration: 0),
                value: kenBurnsScale
            )
        }
        .opacity(isActive ? 1 : 0)
        .animation(.easeInOut(duration: 1.4), value: isActive)
        .ignoresSafeArea()
        .onChange(of: isActive) { _, active in
            if active {
                kenBurnsScale = 1.02
                // Trigger animation after a tiny delay so SwiftUI picks up the value change
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    kenBurnsScale = 1.16
                }
            }
        }
        .onAppear {
            if isActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    kenBurnsScale = 1.16
                }
            }
        }
    }
}

// MARK: - CaptionBlock

private struct CaptionBlock: View {
    let city: City

    var body: some View {
        VStack(spacing: 0) {
            // Coordinates (mono, tracking +0.34em)
            Text(city.coord)
                .font(MGFont.mono(9))
                .tracking(9 * 0.34)
                .foregroundStyle(Color.white.opacity(0.6))
                .padding(.bottom, 4)

            // City name (serif 40)
            Text(city.name)
                .font(MGFont.serif(40, .semibold))
                .foregroundStyle(Color.white)
                .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 2)
                .lineLimit(1)

            // Italic tag (serif italic 15)
            Text(city.tag)
                .font(.custom("CormorantGaramond-Bold", size: 15).italic())
                .foregroundStyle(Color(red: 245/255, green: 235/255, blue: 214/255).opacity(0.82))
                .padding(.top, 2)
        }
        .multilineTextAlignment(.center)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .id(city.name) // force re-render on city change
    }
}
