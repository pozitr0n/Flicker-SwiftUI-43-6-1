//
//  ContentView.swift
//  SwiftUI_43_6_1
//
//  Created by Raman Kozar on 03/06/2023.
//

import SwiftUI

struct FlickerObject: Identifiable {
    
    let id = UUID()
    let flickerTitle: String
    let flickerUrlToImage: String
    let flickerHeight: String
    let flickerWidth: String
    
}

struct ContentView: View {

    @State private var flickerData = [FlickerObject]()
    @State private var searchText = ""
    
    let initFlickerAPI = FlickerAPI()
   
    var body: some View {
        
        NavigationView {
            
            List(flickerData) { info in
                
                NavigationLink(destination: FlickerDetailScreen(flickerItem: info)) {
                    
                    VStack {
                        Text(info.flickerTitle)
                            .padding(.trailing)
                    }
                    
                }
                
            }
            .navigationTitle("Flicker on SwiftUI")
            
        }
        .searchable(text: $searchText, prompt: "Search the image")
        .onSubmit(of: .search) {
            if !searchText.isEmpty {
                initFlickerAPI.getArrayOfData(searchText: searchText) { (arr) in
                    flickerData = arr
                }
            }
        }
        .onAppear {
            initFlickerAPI.getArrayOfData(searchText: searchText) { (arr) in
                flickerData = arr
            }
        }
        
    }
    
}

struct FlickerDetailScreen: View {
    
    let flickerItem: FlickerObject
    
    var body: some View {
     
        VStack(alignment: .leading) {
            
            HStack {
                Text(flickerItem.flickerTitle)
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
            
            }
            
            VStack {
                
                AsyncImage(url: URL(string: flickerItem.flickerUrlToImage), scale: 3) { image in
                    image.imageScale(.medium)
                        .multilineTextAlignment(.center)
                } placeholder: {
                    Image("logo_error")
                        .multilineTextAlignment(.center)
                }
             
                Text(flickerItem.flickerUrlToImage)
                Spacer()
                
            }
            
        }
        .padding()
        .navigationBarTitle(Text("Image size " + flickerItem.flickerWidth + "x" + flickerItem.flickerHeight), displayMode: .inline)
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
