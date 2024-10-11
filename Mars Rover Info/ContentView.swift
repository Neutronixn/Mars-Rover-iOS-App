//
//  ContentView.swift
//  Mars Rover Info
//
//  Created by Vision on 10/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var rover = "curiosity"
    @State private var sol = 1000
    @State private var camera = ""
    @State private var photos: [MarsPhoto] = []
    @State private var isLoading = false
    
    let rovers = ["curiosity", "opportunity", "spirit"]
    let cameras = ["FHAZ", "RHAZ", "MAST", "CHEMCAM", "MAHLI", "MARDI", "NAVCAM", "PANCAM", "MINITES"]
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Picker("Rover", selection: $rover) {
                        ForEach(rovers, id: \.self) { rover in
                            Text(rover.capitalized)
                        }
                    }
                    
                    Stepper("Sol: \(sol)", value: $sol, in: 0...5000)
                    
                    Picker("Camera", selection: $camera) {
                        Text("All Cameras").tag("")
                        ForEach(cameras, id: \.self) { camera in
                            Text(camera).tag(camera)
                        }
                    }
                    
                    Button("Fetch Photos") {
                        fetchPhotos()
                    }
                }
                
                if isLoading {
                    ProgressView()
                } else if photos.isEmpty {
                    Text("No photos to display")
                } else {
                    List(photos, id: \.id) { photo in
                        NavigationLink(destination: PhotoDetailView(photo: photo)) {
                            HStack {
                                SafeAsyncImage(url: URL(string: photo.imgSrc)) { image in
                                    image.resizable().aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 100)
                                
                                VStack(alignment: .leading) {
                                    Text("Camera: \(photo.camera.fullName)")
                                    Text("Earth Date: \(photo.earthDate)")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mars Rover Photos")
        }
    }
    
    func fetchPhotos() {
        isLoading = true
        MarsRoverAPI.shared.fetchPhotos(rover: rover, sol: sol, camera: camera.isEmpty ? nil : camera) { fetchedPhotos, error in
            DispatchQueue.main.async {
                isLoading = false
                if let fetchedPhotos = fetchedPhotos {
                    self.photos = fetchedPhotos
                } else if let error = error {
                    print("Error fetching photos: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct PhotoDetailView: View {
    let photo: MarsPhoto
    
    var body: some View {
        ScrollView {
            VStack {
                SafeAsyncImage(url: URL(string: photo.imgSrc)) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 300)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Photo ID: \(photo.id)")
                    Text("Rover: \(photo.camera.name)")
                    Text("Camera: \(photo.camera.fullName)")
                    Text("Sol: \(photo.sol)")
                    Text("Earth Date: \(photo.earthDate)")
                }
                .padding()
            }
        }
        .navigationTitle("Photo Detail")
    }
}

#Preview {
    ContentView()
}
