//
//  OtherView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI

struct OtherView: View {
    @Binding var swipeToNavigateEnabled: Bool
    var body: some View {
        SwipeToNavigateView(isOn: $swipeToNavigateEnabled)
        ResetSettingsView()
        CreditsView()
    }
}

struct SwipeToNavigateView: View {
    @Binding var isOn: Bool
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Swipe to Navigate")
                
                HStack(spacing: 0) {
                    if isOn {
                        Label(text: "ON")
                    } else {
                        Label(text: "OFF")
                    }
                    Spacer()
                    Toggle(isOn: $isOn, label: {
                        Text("Label")
                    }).labelsHidden()

                }
                .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}

struct ResetSettingsView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Reset Settings")
                
                Button(action: {
                    print("Reset settings")
                }) {
                    HStack {
                        Label(text: "Reset")
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 6))
                }
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}

struct CreditsView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Credits")
                
                NavigationLink(destination: PeopleView()) {
                    HStack(spacing: 0) {
                        Label(text: "People")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                
                Rectangle()
                    .fill(Color(UIColor.white.withAlphaComponent(0.3)))
                    .frame(height: 1)
                
                NavigationLink(destination: Text("Licenses")) {
                    HStack(spacing: 0) {
                        Label(text: "Licenses")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}
