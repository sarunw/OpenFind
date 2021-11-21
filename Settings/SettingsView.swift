//
//  SettingsView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI
import Combine
import LinkPresentation


class Settings: ObservableObject {
    @Published var highlightColor: String { didSet { UserDefaults.standard.set(highlightColor, forKey: "highlightColor") } }
    @Published var recognitionLanguages: [String] { didSet { UserDefaults.standard.set(recognitionLanguages, forKey: "recognitionLanguages") } }
    @Published var showTextDetectIndicator: Bool { didSet { UserDefaults.standard.set(showTextDetectIndicator, forKey: "showTextDetectIndicator") } }
    @Published var shutterStyle: Int { didSet { UserDefaults.standard.set(shutterStyle, forKey: "shutterStyle") } }
    @Published var hapticFeedbackLevel: Int { didSet { UserDefaults.standard.set(hapticFeedbackLevel, forKey: "hapticFeedbackLevel") } }
    @Published var swipeToNavigateEnabled: Bool { didSet { UserDefaults.standard.set(swipeToNavigateEnabled, forKey: "swipeToNavigateEnabled") } }
    
    init() {
        self.highlightColor = UserDefaults.standard.string(forKey: "highlightColor") ?? "00AEEF"
        self.recognitionLanguages = UserDefaults.standard.array(forKey: "recognitionLanguages") as? [String] ?? []
        self.showTextDetectIndicator = UserDefaults.standard.bool(forKey: "showTextDetectIndicator")
        self.shutterStyle = UserDefaults.standard.integer(forKey: "shutterStyle")
        self.hapticFeedbackLevel = UserDefaults.standard.integer(forKey: "hapticFeedbackLevel")
        self.swipeToNavigateEnabled = UserDefaults.standard.bool(forKey: "swipeToNavigateEnabled")
    }
}

public class SettingsViewController: UIViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dismissed: (() -> Void)?
    
    public override func loadView() {
        
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        
        var settingsView = SettingsView()
        
        /**
         Set the dismiss button handler.
         */
        settingsView.donePressed = { [weak self] in
            Bridge.dismissed?()
            self?.dismiss(animated: true, completion: nil)
        }
        
        let hostedSettings = UIHostingController(rootView: settingsView)
        
        self.addChild(hostedSettings)
        view.addSubview(hostedSettings.view)
        hostedSettings.view.frame = view.bounds
        hostedSettings.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedSettings.didMove(toParent: self)
        
    }
}

extension SettingsViewController {
    func shareApp() {
        let link = URL(string: "https://getfind.app/")!
        
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(activityItems: [link, self], applicationActivities: nil)
            
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceRect = CGRect(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2 + 200, width: 20, height: 20)
                popoverController.sourceView = self.view
            }
            
            self.present(activityViewController, animated: true)
            
        }
    }
}


extension SettingsViewController: UIActivityItemSource {
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }
    
    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }
    
    public func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        
        let appIcon = UIImage(named: "AppIconSmall")!
        let imageProvider = NSItemProvider(object: appIcon)
        let metadata = LPLinkMetadata()
        metadata.title = "Find"
        metadata.originalURL = URL(fileURLWithPath: "getfind.app")
        metadata.imageProvider = imageProvider
        return metadata
    }
}



struct SettingsView: View {
    
    @ObservedObject var settings = Settings()
    var donePressed: (() -> Void)?
    
    @State var isShowingQR = false
    
    var body: some View {
        ZStack {
            Color(.black).brightness(0.1).edgesIgnoringSafeArea(.all)
                .zIndex(0)
            
            NavigationView {
                ZStack {
                    ScrollView {
                        VStack(spacing: 16) {
                            
                            VStack(spacing: 8) {
                                SectionHeaderView(text: "General")
                                    .accessibility(addTraits: .isHeader)
                                    .accessibility(hint: Text("Options for the entire app"))
                                
                                GeneralView(selectedHighlightColor: $settings.highlightColor)
                            }
                            
                            VStack(spacing: 8) {
                                SectionHeaderView(text: "Camera")
                                    .accessibility(addTraits: .isHeader)
                                    .accessibility(hint: Text("Customize the camera's behavior"))
                                
                                CameraSettingsView(
                                    textDetectionIsOn: $settings.showTextDetectIndicator,
                                    hapticFeedbackLevel: $settings.hapticFeedbackLevel,
                                    shutterStyle: $settings.shutterStyle
                                )
                            }
                            
                            VStack(spacing: 8) {
                                SectionHeaderView(text: "Support & Feedback")
                                    .accessibility(addTraits: .isHeader)
                                    .accessibility(hint: Text("Get help and send feedback. I will respond very quickly to everything that is accessibility related."))
                                
                                SupportView()
                            }
                            
                            VStack(spacing: 8) {
                                SectionHeaderView(text: "Other")
                                    .accessibility(addTraits: .isHeader)
                                    .accessibility(hint: Text("Miscellaneous settings"))
                                
                                OtherView(
                                    swipeToNavigateEnabled: $settings.swipeToNavigateEnabled,
                                    isShowingQR: $isShowingQR,
                                    allSettings: settings
                                )
                                
                            }
                            
                            HStack(spacing: 0) {
                                
                                Text("Version ")
                                    .foregroundColor(Color.white.opacity(0.75))
                                    .font(Font.system(size: 15, weight: .medium))
                                
                                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                                    .foregroundColor(Color.white.opacity(0.75))
                                    .font(Font.system(size: 15, weight: .medium))
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12))
                                
                                
                                Button(action: {
                                    Bridge.presentWhatsNew?()
                                }) {
                                    Text("See what's new")
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .font(Font.system(size: 15, weight: .medium))
                                }
                            }
                        }
                        .edgePadding()
                        
                    }
                    .fixFlickering { scrollView in
                        scrollView
                            .background(
                                VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialDark))
                            )
                    }
                }
                .navigationBarTitle("Settings")
                .navigationBarItems(
                    trailing:
                        Button(action: {
                            donePressed?()
                        }) {
                            Text("done")
                                .font(Font.system(size: 19, weight: .regular, design: .default))
                                .accessibility(hint: Text("Return to the camera screen"))
                        }
                )
                .configureBar()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .zIndex(1)
            .accessibility(hidden: isShowingQR)
            .opacity(isShowingQR ? 0 : 1)
            
            if isShowingQR {
                QRCodeView(isPresented: $isShowingQR)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
    }
}

extension ScrollView {
    
    public func fixFlickering() -> some View {
        
        return self.fixFlickering { (scrollView) in
            return scrollView
        }
    }
    
    public func fixFlickering<T: View>(@ViewBuilder configurator: @escaping (ScrollView<AnyView>) -> T) -> some View {
        
        GeometryReader { geometryWithSafeArea in
            GeometryReader { geometry in
                configurator(
                    ScrollView<AnyView>(self.axes, showsIndicators: self.showsIndicators) {
                        AnyView(
                            VStack {
                                self.content
                            }
                                .padding(.top, geometryWithSafeArea.safeAreaInsets.top)
                                .padding(.bottom, geometryWithSafeArea.safeAreaInsets.bottom)
                                .padding(.leading, geometryWithSafeArea.safeAreaInsets.leading)
                                .padding(.trailing, geometryWithSafeArea.safeAreaInsets.trailing)
                        )
                    }
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}