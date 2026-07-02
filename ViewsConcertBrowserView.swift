//
//  ConcertBrowserView.swift
//  VenU
//
//  Created by Samir Varma on 6/21/26.
//

import SwiftUI

struct ConcertBrowserView: View {
    @StateObject private var repository = ConcertRepository()
    @State private var concerts: [Concert] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading concerts...")
                } else if concerts.isEmpty {
                    emptyStateView
                } else {
                    concertListView
                }
            }
            .navigationTitle("Concerts")
            .searchable(text: $searchText, prompt: "Search artists...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // TODO: Add concert action
                    } label: {
                        Label("Add Concert", systemImage: "plus")
                    }
                }
            }
            .task {
                await loadConcerts()
            }
            .refreshable {
                await loadConcerts()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Views
    
    private var concertListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredConcerts) { concert in
                    NavigationLink {
                        // TODO: Concert detail view
                        ConcertDetailPlaceholder(concert: concert)
                    } label: {
                        ConcertRowView(concert: concert)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Concerts Yet", systemImage: "music.note.list")
        } description: {
            Text("Check back soon for upcoming shows, or add one yourself!")
        } actions: {
            Button("Add Concert") {
                // TODO: Add concert action
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredConcerts: [Concert] {
        if searchText.isEmpty {
            return concerts
        } else {
            return concerts.filter { concert in
                concert.artistName.localizedCaseInsensitiveContains(searchText) ||
                concert.genre.localizedCaseInsensitiveContains(searchText) ||
                concert.venueName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Methods
    
    private func loadConcerts() async {
        isLoading = true
        
        do {
            concerts = try await repository.fetchUpcomingConcerts()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
}

// MARK: - Placeholder Detail View

struct ConcertDetailPlaceholder: View {
    let concert: Concert
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(concert.artistName)
                        .font(.largeTitle.bold())
                    
                    Text(concert.name)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                        Text(concert.venueName)
                    }
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text(concert.date, style: .date)
                        Image(systemName: "clock")
                        Text(concert.date, style: .time)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // Details
                VStack(alignment: .leading, spacing: 12) {
                    if let genre = concert.genre {
                        DetailRow(title: "Genre", value: genre)
                    }
                    
                    if let priceRange = concert.priceRange {
                        DetailRow(title: "Price Range", value: priceRange)
                    }
                }
                
                Spacer()
                
                // Action Button
                Button {
                    // TODO: Mark as attending
                } label: {
                    Label("I'm Going!", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle("Concert Details")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
        }
    }
}

#Preview {
    ConcertBrowserView()
}
