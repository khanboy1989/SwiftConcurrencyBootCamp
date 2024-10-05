//
//  SearchableBootcamp.swift
//  SwiftConcurencyBootcamp
//
//  Created by Serhan Khan on 24/09/2024.
//

import SwiftUI
import Combine

// MARK: - Data Model
struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    let cuisine: CuisineOption
}

enum CuisineOption: String {
    case american, italian, japanese
}

// MARK: - Restaurant Manager
final class RestaurantManager {
    func getAllRestaurants() async throws -> [Restaurant] {
        return [
            Restaurant(id: "1", title: "Burger Shack", cuisine: .american),
            Restaurant(id: "2", title: "Pasta Palace", cuisine: .italian),
            Restaurant(id: "3", title: "Sushi Heaven", cuisine: .japanese),
            Restaurant(id: "4", title: "Local Market", cuisine: .american)
        ]
        
    }
}

@MainActor
final class SearchableBootcampViewModel: ObservableObject {
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
    let manager = RestaurantManager()
    
    var showSeachSuggestion: Bool {
        searchText.count < 5
    }
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    enum SearchScopeOption: Hashable {
        case all
        case cuisine(option: CuisineOption)
        
        var title: String {
            switch self {
            case .all:
                return "All"
            case let .cuisine(option):
                return option.rawValue.capitalized
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] searchText, searchScope in
                self?.filterRestaurants(searchText: searchText, currentSearchScope: searchScope)
            }).store(in: &cancellables)
    }
    
    private func filterRestaurants(searchText: String, currentSearchScope: SearchScopeOption) {
        guard !searchText.isEmpty else {
            filteredRestaurants = []
            self.searchScope = .all
            return
        }
        //Filter on Search Scope
        var restaurantsInScope = allRestaurants
        switch currentSearchScope {
        case .all:
            break
        case let .cuisine(option):
            restaurantsInScope = allRestaurants.filter({ $0.cuisine == option })
        }
        
        //Filter on SearchText
        let search = searchText.lowercased()
        filteredRestaurants = restaurantsInScope.filter({ restaurant in
            let titleContainsSearch = restaurant.title.lowercased().contains(search)
            let cousineContainsSearch = restaurant.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSearch || cousineContainsSearch
        })
    }
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
            let allCuisines = Set(allRestaurants.map { $0.cuisine })
            allSearchScopes = [.all] + allCuisines.map({ SearchScopeOption.cuisine(option: $0) })
        } catch {
            print(error)
        }
    }
    
    func getSearchSuggestions() -> [String] {
        guard showSeachSuggestion else { return []}
        var suggestions:[String] = []
        let search = searchText.lowercased()
        
        if search.contains("pa") {
            suggestions.append("Pasta")
        }
        
        if search.contains("su") {
            suggestions.append("Sushi")
        }
        
        if search.contains("bu") {
            suggestions.append("Burger")
        }
            
        
        suggestions.append("Market")
        suggestions.append("Grocery")
        
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        suggestions.append(CuisineOption.japanese.rawValue.capitalized)
        suggestions.append(CuisineOption.american.rawValue.capitalized)

        return suggestions
    }
    
    func getRestaurantSuggestions() -> [Restaurant] {
        guard showSeachSuggestion else { return []}
        var suggestions:[Restaurant] = []
        let search = searchText.lowercased()
        
        if search.contains("ita") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .italian }))
        }
        
        if search.contains("jap") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .japanese }))
        }
        
        return suggestions
    }
}

struct SearchableBootcamp: View {
    
    @StateObject private var viewModel = SearchableBootcampViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.isSearching ? viewModel.filteredRestaurants : viewModel.allRestaurants) { restaurant in
                        NavigationLink(value: restaurant) {
                            restaurantRow(restaurant: restaurant)
                        }
                    }
                }.padding()
                //                SearchChildView()
                //                Text("View Model is searching: \(viewModel.isSearching)")
            }.searchable(text: $viewModel.searchText, placement: .automatic, prompt: Text("Search Restaurants...")) //Default Searchbar from the native SwiftUI
                .searchScopes($viewModel.searchScope, scopes: {
                    ForEach(viewModel.allSearchScopes, id: \.self) { scope in
                        Text(scope.title)
                            .tag(scope)
                    }
                }).searchSuggestions({
                    ForEach(viewModel.getSearchSuggestions(), id: \.self) { suggestion in
                        Text(suggestion)
                            .searchCompletion(suggestion)
                    }
                    ForEach(viewModel.getRestaurantSuggestions(), id: \.self) { suggestion in
                        NavigationLink(value: suggestion) {
                            Text(suggestion.title)
                        }
                    }
                })
            //.navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Restaurants")
                .task {
                    await viewModel.loadRestaurants()
                }.navigationDestination(for: Restaurant.self, destination: { restaurant in
                    Text(restaurant.title.capitalized)
                })
        }
    }
    
    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading) {
            Text(restaurant.title)
                .font(.headline)
                .foregroundStyle(.red)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(.black)
        }.padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.05))
    }
}

struct SearchChildView: View {
    
    //pulling isSearching from env. It has to be in the childview
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        Text("Search ChildView is Searching: \(isSearching)")
    }
}

#Preview {
    SearchableBootcamp()
}
