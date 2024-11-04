//
//  SleepingView.swift
//  LiWake
//
//  Created by Qiandao Liu on 11/2/24.
//

import SwiftUI

struct SleepingView: View {
    var body: some View {

        
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview(traits: .landscapeRight) {
    SleepingView()
}
