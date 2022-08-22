//
//  AppSettingsView.swift
//  PlayCover
//
//  Created by Isaac Marovitz on 14/08/2022.
//

import SwiftUI

struct AppSettingsView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var viewModel: AppSettingsVM

    @State var resetSettingsCompletedAlert: Bool = false
    @State var resetKmCompletedAlert: Bool = false

    var body: some View {
        VStack {
            HStack {
                if let img = viewModel.app.icon {
                    Image(nsImage: img).resizable()
                        .frame(width: 33, height: 33)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                }
                Text("\(viewModel.app.name) " + NSLocalizedString("settings.title", comment: ""))
                    .font(.title2).bold()
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            TabView {
                KeymappingView(settings: $viewModel.settings)
                    .tabItem {
                        Text("settings.tab.km")
                    }
                GraphicsView(settings: $viewModel.settings)
                    .tabItem {
                        Text("settings.tab.graphics")
                    }
                JBBypassView(settings: $viewModel.settings)
                    .tabItem {
                        Text("settings.tab.jbBypass")
                    }
                InfoView(info: viewModel.app.info)
                    .tabItem {
                        Text("settings.tab.info")
                    }
            }
            .frame(minWidth: 450, minHeight: 200)
            HStack {
                Spacer()
                Button("settings.resetSettings") {
                    resetSettingsCompletedAlert.toggle()
                    viewModel.app.settings.reset()
                    dismiss()
                }
                Button("settings.resetKm") {
                    resetKmCompletedAlert.toggle()
                    // TODO: Make these buttons do different things lol
                    viewModel.app.settings.reset()
                    dismiss()
                }
                Button("button.OK") {
                    dismiss()
                }
                .tint(.accentColor)
                .keyboardShortcut(.defaultAction)
            }
        }
        .onChange(of: resetSettingsCompletedAlert) { _ in
            ToastVM.shared.showToast(toastType: .notice,
                toastDetails: NSLocalizedString("settings.resetSettingsCompleted", comment: ""))
        }
        .onChange(of: resetKmCompletedAlert) { _ in
            ToastVM.shared.showToast(toastType: .notice,
                toastDetails: NSLocalizedString("settings.resetKmCompleted", comment: ""))
        }
        .padding()
    }
}

struct KeymappingView: View {
    @Binding var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Toggle("settings.toggle.km", isOn: $settings.settings.keymapping)
                        .help("settings.toggle.km.help")
                    Spacer()
                    Toggle("settings.toggle.mm", isOn: $settings.settings.mouseMapping)
                        .help("settings.toggle.mm.help")
                }
                HStack {
                    Text(NSLocalizedString("settings.slider.mouseSensitivity", comment: "")
                         + String(format: "%.f", settings.settings.sensitivity))
                    Spacer()
                    Slider(value: $settings.settings.sensitivity, in: 0...100, label: {EmptyView()})
                    .frame(width: 250)
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct GraphicsView: View {
    @Binding var settings: AppSettings

    @State var customWidth: Int = 1920
    @State var customHeight: Int = 1080

    static var number: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("settings.picker.iosDevice")
                    Spacer()
                    Picker("", selection: $settings.settings.iosDeviceModel) {
                        Text("iPad Pro (12.9-inch) (1st gen) | A9X | 4GB").tag("iPad6,7")
                        Text("iPad Pro (12.9-inch) (3rd gen) | A12Z | 4GB").tag("iPad8,6")
                        Text("iPad Pro (12.9-inch) (5th gen) | M1 | 8GB").tag("iPad13,8")
                    }
                    .frame(width: 250)
                }
                HStack {
                    Text("settings.picker.adaptiveRes")
                    Spacer()
                    Picker("", selection: $settings.settings.resolution) {
                        Text("settings.picker.adaptiveRes.0").tag(0)
                        Text("settings.picker.adaptiveRes.1").tag(1)
                        Text("1080p").tag(2)
                        Text("1440p").tag(3)
                        Text("4K").tag(4)
                        Text("settings.picker.adaptiveRes.5").tag(5)
                    }
                    .frame(width: 250, alignment: .leading)
                    .help("settings.picker.adaptiveRes.help")
                }
                HStack {
                    if settings.settings.resolution == 5 {
                        Text(NSLocalizedString("settings.text.customWidth", comment: "") + ":")
                        Stepper {
                            TextField("settings.text.customWidth", value: $customWidth,
                                      formatter: GraphicsView.number,
                                      onCommit: {
                                        DispatchQueue.main.async {
                                            NSApp.keyWindow?.makeFirstResponder(nil)
                                        }
                                      })
                            .frame(width: 125)
                        }
                        onIncrement: {
                            customWidth += 1
                        } onDecrement: {
                            customWidth -= 1
                        }
                        Spacer()
                        Text(NSLocalizedString("settings.text.customHeight", comment: "") + ":")
                        Stepper {
                            TextField("settings.text.customHeight", value: $customHeight,
                                      formatter: GraphicsView.number,
                                      onCommit: {
                                        DispatchQueue.main.async {
                                            NSApp.keyWindow?.makeFirstResponder(nil)
                                        }
                                      })
                            .frame(width: 125)
                        } onIncrement: {
                            customHeight += 1
                        } onDecrement: {
                            customHeight -= 1
                        }
                    } else if settings.settings.resolution >= 2 && settings.settings.resolution <= 4 {
                        Text("settings.picker.aspectRatio")
                        Spacer()
                        Picker("", selection: $settings.settings.aspectRatio) {
                            Text("4:3").tag(0)
                            Text("16:9").tag(1)
                            Text("16:10").tag(2)
                        }
                        .pickerStyle(.radioGroup)
                        .horizontalRadioGroupLayout()
                    }
                }
                HStack {
                    Picker("settings.picker.refreshRate", selection: $settings.settings.refreshRate) {
                        Text("60 Hz").tag(60)
                        Text("120 Hz").tag(120)
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                    .frame(alignment: .leading)
                    Spacer()
                    Toggle("settings.toggle.disableDisplaySleep", isOn: $settings.settings.disableTimeout)
                        .help("settings.toggle.disableDisplaySleep.help")
                }
                Spacer()
            }
            .padding()
            .onAppear {
                customWidth = settings.settings.windowWidth
                customHeight = settings.settings.windowHeight
            }
            .onChange(of: settings.settings.resolution) { _ in
                setResolution()
            }
            .onChange(of: settings.settings.aspectRatio) { _ in
                setResolution()
            }
            .onChange(of: customWidth) { _ in
                setResolution()
            }
            .onChange(of: customHeight) { _ in
                setResolution()
            }
        }
    }

    func setResolution() {
        var width: Int
        var height: Int

        switch settings.settings.resolution {
        // Adaptive resolution = Auto
        case 1:
            width = Int(NSScreen.main?.visibleFrame.width ?? 1920)
            height = Int(NSScreen.main?.visibleFrame.width ?? 1080)
        // Adaptive resolution = 1080p
        case 2:
            height = 1080
            width = getWidthFromAspectRatio(height)
        // Adaptive resolution = 1440p
        case 3:
            height = 1440
            width = getWidthFromAspectRatio(height)
        // Adaptive resolution = 4K
        case 4:
            height = 2160
            width = getWidthFromAspectRatio(height)
        // Adaptive resolution = Custom
        case 5:
            width = customWidth
            height = customHeight
        // Adaptive resolution = Off
        default:
            width = 1920
            height = 1080
        }

        settings.settings.windowWidth = width
        settings.settings.windowHeight = height
    }

    func getWidthFromAspectRatio(_ height: Int) -> Int {
        var widthRatio: Int
        var heightRatio: Int

        switch settings.settings.aspectRatio {
        case 0:
            widthRatio = 4
            heightRatio = 3
        case 1:
            widthRatio = 16
            heightRatio = 9
        case 2:
            widthRatio = 16
            heightRatio = 10
        default:
            widthRatio = 16
            heightRatio = 9
        }
        return (height / heightRatio) * widthRatio
    }
}

struct JBBypassView: View {
    @Binding var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Toggle("settings.toggle.jbBypass", isOn: $settings.settings.bypass)
                        .help("settings.toggle.jbBypass.help")
                    Spacer()
                }
            }
            .padding()
        }
    }
}

struct InfoView: View {
    @State var info: AppInfo

    var body: some View {
        List {
            HStack {
                Text("Display name:")
                Spacer()
                Text("\(info.displayName)")
            }
            HStack {
                Text("Bundle name:")
                Spacer()
                Text("\(info.bundleName)")
            }
            HStack {
                Text("Bundle identifier:")
                Spacer()
                Text("\(info.bundleIdentifier)")
            }
            HStack {
                Text("Bundle version:")
                Spacer()
                Text("\(info.bundleVersion)")
            }
            HStack {
                Text("Executable name:")
                Spacer()
                Text("\(info.executableName)")
            }
            HStack {
                Text("Minimum OS version:")
                Spacer()
                Text("\(info.minimumOSVersion)")
            }
            HStack {
                Text("URL:")
                Spacer()
                Text("\(info.url)")
            }
            HStack {
                Text("Is Game:")
                Spacer()
                Text("\(info.isGame ? "Yes" : "No")")
            }
        }
        .listStyle(.bordered(alternatesRowBackgrounds: true))
        .padding()
    }
}
