//
//  ContentView.swift
//  Callback_vs_AsynAwait
//
//  Created by EstrHuP on 18/7/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            AsyncImage(url: viewModel.characterBasicInfo.image)
            Text("Name: \(viewModel.characterBasicInfo.name)")
            Text("First Episode: \(viewModel.characterBasicInfo.firstEpisodeTitle)")
            Text("Dimension: \(viewModel.characterBasicInfo.dimension)")
        }.onAppear {
            viewModel.executeRequest()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
