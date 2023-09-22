//
//  ContentView.swift
//  Callback_vs_AsynAwait
//
//  Created by EstrHuP on 18/7/23.
//

import SwiftUI

struct ContentView: View {
    
    let viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .onAppear {
            viewModel.executeRequest()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
