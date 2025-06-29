//
//MIT License
//
//Copyright © 2025 Cong Le
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//
//
//  NeuronalMigrationView.swift
//  Neuronal_Migration
//
//  Created by Cong Le on 6/29/25.
//

import SwiftUI

// MARK: - Constants
/// A centralized structure to hold constants for styling and layout, improving maintainability.
fileprivate enum MigrationConstants {
    enum Colors {
        static let background = Color(.systemGroupedBackground)
        static let text = Color(.label)
        
        // Zone colors
        static let corticalPlate = Color.blue.opacity(0.2)
        static let intermediateZone = Color.green.opacity(0.2)
        static let ventricularZone = Color.purple.opacity(0.2)
        
        // Neuron colors
        static let radialNeuron = Color.blue
        static let tangentialNeuron = Color.orange
        static let multipolarNeuron = Color.red
        
        // Path colors
        static let radialGlia = Color.gray.opacity(0.7)
    }
    
    enum Layout {
        static let zoneHeight: CGFloat = 150
        static let neuronSize: CGFloat = 20
        static let padding: CGFloat = 16
    }
    
    enum Animation {
        static let duration: Double = 3.0
        static let multipolarPhaseDuration: Double = 1.5
    }
}

// MARK: - Main Migration View
/// A SwiftUI view that visually demonstrates the three main types of neuronal migration
/// during corticogenesis.
///
/// This view presents a simplified model of the cortical zones and animates neurons
/// moving via radial, tangential, and multipolar migration patterns. It includes
/// controls to start and repeat the animation.
public struct NeuronalMigrationView: View {
    
    /// State to trigger and control the animations. When true, migrations are in progress.
    @State private var isMigrating = false
    /// State to track if the animation has finished, used to show the repeat button.
    @State private var animationCompleted = false

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("The Journey of a Neuron 🧠")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)

                    Text("Neurons born deep in the brain must travel to their final destination in the cortex. This view demonstrates the three primary modes of this incredible journey.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Description of the neuronal migration visualization.")
                }
                .padding(.horizontal, MigrationConstants.Layout.padding)

                // MARK: Visualization Canvas
                migrationCanvas
                    .frame(height: MigrationConstants.Layout.zoneHeight * 3)
                    .padding(.vertical)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("An animated visualization of three neurons migrating across brain zones.")

                // MARK: Control Buttons
                VStack {
                    if animationCompleted {
                        // Shows the button to repeat the animation after it has finished.
                        createControlButton(
                            title: "Repeat Migration",
                            systemImage: "arrow.clockwise",
                            backgroundColor: .green,
                            action: resetAnimation
                        )
                    } else {
                        // Shows the button to start the animation. It's disabled during migration.
                        createControlButton(
                            title: isMigrating ? "Migrating..." : "Start Migration",
                            systemImage: isMigrating ? "arrow.up.right.and.arrow.down.left.rectangle.fill" : "play.fill",
                            backgroundColor: isMigrating ? .gray : .blue,
                            action: startAnimation
                        )
                        .disabled(isMigrating)
                    }
                }
                .padding(.horizontal, MigrationConstants.Layout.padding)

            }
            .padding(.vertical)
        }
        .background(MigrationConstants.Colors.background)
    }

    /// The main canvas where the zones and migrating neurons are drawn.
    private var migrationCanvas: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Zones
                VStack(spacing: 0) {
                    ZoneView(title: "Cortical Plate (Destination)", color: MigrationConstants.Colors.corticalPlate)
                    ZoneView(title: "Intermediate Zone", color: MigrationConstants.Colors.intermediateZone)
                    ZoneView(title: "Ventricular Zone (Origin)", color: MigrationConstants.Colors.ventricularZone)
                }
                
                let thirdWidth = geometry.size.width / 3
                
                // Animated Neuron Representations
                HStack(spacing: 0) {
                    RadialNeuronView(isMigrating: $isMigrating)
                        .frame(width: thirdWidth)
                    
                    TangentialNeuronView(isMigrating: $isMigrating)
                        .frame(width: thirdWidth)
                    
                    MultipolarNeuronView(isMigrating: $isMigrating)
                        .frame(width: thirdWidth)
                }
            }
        }
    }
    
    // MARK: - Control Logic
    
    /// A helper function to create styled buttons, reducing code duplication.
    private func createControlButton(title: String, systemImage: String, backgroundColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .animation(.easeOut, value: title)
        }
    }
    
    /// Starts the migration animation and schedules its completion.
    private func startAnimation() {
        // Trigger the animation for all neuron views.
        withAnimation(.easeInOut(duration: MigrationConstants.Animation.duration)) {
            self.isMigrating = true
        }
        
        // After the animation duration, update the state to show the 'Repeat' button.
        DispatchQueue.main.asyncAfter(deadline: .now() + MigrationConstants.Animation.duration) {
            self.isMigrating = false
            self.animationCompleted = true
        }
    }
    
    /// Resets all state variables to their initial values to allow re-playing the animation.
    private func resetAnimation() {
        self.animationCompleted = false
        // isMigrating is already false, but we set it explicitly to trigger `onChange` in child views.
        self.isMigrating = false
    }
}

// MARK: - Helper Views

/// A simple view representing a developmental zone in the cortex.
private struct ZoneView: View {
    let title: String
    let color: Color

    var body: some View {
        color
            .overlay(
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(4)
                    .background(.thinMaterial)
                    .clipShape(Capsule())
                    .accessibilityLabel("Zone: \(title)")
            )
    }
}

// MARK: - Neuron Migration Types

/// Visualizes a neuron performing radial migration along a glial cell fiber.
private struct RadialNeuronView: View {
    @Binding var isMigrating: Bool
    
    var body: some View {
        let C = MigrationConstants.Layout.self
        let colors = MigrationConstants.Colors.self
        
        GeometryReader { geometry in
            let startPoint = CGPoint(x: geometry.size.width / 2, y: geometry.size.height - C.neuronSize)
            let endPoint = CGPoint(x: geometry.size.width / 2, y: C.neuronSize)
            
            // Path for the radial glia fiber
            Path { path in
                path.move(to: startPoint)
                path.addLine(to: endPoint)
            }
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
            .foregroundColor(colors.radialGlia)

            // The migrating neuron
            Circle()
                .fill(colors.radialNeuron)
                .frame(width: C.neuronSize, height: C.neuronSize)
                .position(isMigrating ? endPoint : startPoint)
                .overlay(
                    Text("1")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.white)
                        .allowsHitTesting(false)
                )
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Text("1. Radial")
                .font(.footnote)
                .bold()
                .padding(4)
        }
    }
}

/// Visualizes a neuron (typically an interneuron) performing tangential migration.
private struct TangentialNeuronView: View {
    @Binding var isMigrating: Bool

    var body: some View {
        let C = MigrationConstants.Layout.self
        let colors = MigrationConstants.Colors.self
        
        GeometryReader { geometry in
            let startPoint = CGPoint(x: C.neuronSize, y: geometry.size.height / 2)
            let endPoint = CGPoint(x: geometry.size.width - C.neuronSize, y: geometry.size.height / 2)

            // The migrating neuron
            Circle()
                .fill(colors.tangentialNeuron)
                .frame(width: C.neuronSize, height: C.neuronSize)
                .position(isMigrating ? endPoint : startPoint)
                .overlay(
                    Text("2")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.white)
                        .allowsHitTesting(false)
                )
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Text("2. Tangential")
                .font(.footnote)
                .bold()
                .padding(4)
        }
    }
}

/// Visualizes the more complex multipolar migration pattern.
/// The animation is sequenced: first a "wobble" phase, then a direct radial phase.
private struct MultipolarNeuronView: View {
    @Binding var isMigrating: Bool
    
    /// Controls the "wobble" phase of multipolar migration.
    @State private var multipolarPhase: CGFloat = 0
    
    /// Controls the final radial migration phase.
    @State private var radialPhase: CGFloat = 0

    var body: some View {
        let C = MigrationConstants.Layout.self
        let colors = MigrationConstants.Colors.self
        
        GeometryReader { geometry in
            let startY = geometry.size.height - C.neuronSize * 2
            let wobbleEndY = geometry.size.height * 0.6
            let finalEndY = C.neuronSize
            let midX = geometry.size.width / 2

            // Static path showing the complex journey
            MultipolarPath(
                startX: midX,
                startY: startY,
                endY: wobbleEndY,
                waveMagnitude: geometry.size.width / 4
            )
            .stroke(colors.multipolarNeuron.opacity(0.3), style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))

            Path { path in
                path.move(to: CGPoint(x: midX, y: wobbleEndY))
                path.addLine(to: CGPoint(x: midX, y: finalEndY))
            }
            .stroke(colors.multipolarNeuron.opacity(0.3), style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
            
            // The neuron that will animate along the path
            Circle()
                .fill(colors.multipolarNeuron)
                .frame(width: C.neuronSize, height: C.neuronSize)
                .position(
                    x: positionOnMultipolarPath(
                        progress: multipolarPhase,
                        startX: midX,
                        magnitude: geometry.size.width / 4),
                    y: startY + (wobbleEndY - startY) * multipolarPhase
                )
                // Once the first phase ends, we modify the y position based on the second phase
                .offset(y: (finalEndY - wobbleEndY) * radialPhase)
                .overlay(
                    Text("3")
                        .font(.caption2)
                        .bold()
                        .foregroundColor(.white)
                        .allowsHitTesting(false)
                )
                .accessibilityHidden(true)
        }
        .onChange(of: isMigrating) {
            // When migration starts, sequence the two animation phases.
            if isMigrating {
                // Phase 1: Multipolar wobble
                withAnimation(.easeInOut(duration: MigrationConstants.Animation.multipolarPhaseDuration)) {
                    multipolarPhase = 1.0
                }
                
                // Phase 2: Radial climb
                withAnimation(
                    .easeInOut(duration: MigrationConstants.Animation.duration - MigrationConstants.Animation.multipolarPhaseDuration)
                    .delay(MigrationConstants.Animation.multipolarPhaseDuration)
                ) {
                    radialPhase = 1.0
                }
            } else {
                // Reset internal state when not migrating.
                // This is crucial for the 'Repeat' button functionality.
                multipolarPhase = 0
                radialPhase = 0
            }
        }
        .overlay(alignment: .bottom) {
            Text("3. Multipolar")
                .font(.footnote)
                .bold()
                .padding(4)
        }
    }
    
    /// Calculates the x-position for the "wobble" effect of multipolar migration.
    private func positionOnMultipolarPath(progress: CGFloat, startX: CGFloat, magnitude: CGFloat) -> CGFloat {
        // A sine wave creates the side-to-side wobble.
        return startX + sin(progress * .pi * 4) * magnitude * (1 - progress)
    }
    
    /// A Shape that draws the "wobble" path of the multipolar neuron.
    private struct MultipolarPath: Shape {
        let startX: CGFloat
        let startY: CGFloat
        let endY: CGFloat
        let waveMagnitude: CGFloat

        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: startX, y: startY))
            
            for i in 1...100 {
                let progress = CGFloat(i) / 100.0
                let y = startY + (endY - startY) * progress
                let x = startX + sin(progress * .pi * 4) * waveMagnitude * (1 - progress)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            return path
        }
    }
}


// MARK: - Preview
#Preview {
    NeuronalMigrationView()
}
