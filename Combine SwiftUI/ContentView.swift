//
//  ContentView.swift
//  Combine SwiftUI
//
//  Created by Kalyanasundaram, Dhivya (Cognizant) on 26/02/25.
//

import SwiftUI
import Combine

struct Post: Decodable {
    let id: Int
    let title: String
    let body: String
}
class PostViewModel: ObservableObject {
    // Published property to notify view of data changes
    @Published var posts: [Post] = []
    
    private var cancellable: AnyCancellable?
    
    init() {
        fetchPosts()
        print("hello")
    }
    
    func fetchPosts() {
        // Replace with your API endpoint URL
        let urlString = "https://jsonplaceholder.typicode.com/posts"
        
        guard let url = URL(string: urlString) else { return }
        
        // Create a URLSession data task publisher
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data) // Extract data from response
            .decode(type: [Post].self, decoder: JSONDecoder()) // Decode JSON into array of Posts
            .replaceError(with: []) // Replace errors with an empty array
            .receive(on: DispatchQueue.main) // Receive on main queue to update UI
            .sink(receiveValue: { [weak self] fetchedPosts in
                self?.posts = fetchedPosts // Update posts with fetched data
            })
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = PostViewModel()
    var body: some View {
        NavigationView {
            List(viewModel.posts, id: \.id) { post in
                VStack(alignment: .leading) {
                    Text(post.title)
                        .font(.headline)
                    Text(post.body)
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Posts")
        }
    }
}

#Preview {
    ContentView()
}
