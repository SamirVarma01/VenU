//
//  ConcertRowView.swift
//  VenU
//
//  Created by Samir Varma on 6/21/26.
//

import SwiftUI

struct ConcertRowView: View {
    let concert: Concert
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Artist Name
            Text(concert.artistName)
                .font(.title2.bold())
                .foregroundStyle(.primary)
            
            // Venue and Date
            HStack(spacing: 16) {
                // Date/Time
                VStack(alignment: .leading, spacing: 4) {
                    Label {
                        Text(concert.date, style: .date)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    
                    Label {
                        Text(concert.date, style: .time)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "clock")
                    }
                }
                
                Spacer()
                
                // Attendees count (placeholder)
                VStack(spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                    Text("0 going")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Genre
            if let genre = concert.genre, !genre.isEmpty {
                Text(genre)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
            
            // Price Range
            if let priceRange = concert.priceRange {
                Text(priceRange)
                    .font(.subheadline.bold())
                    .foregroundStyle(.green)
            }
        }
        .padding()
#if os(iOS)
        .background(Color(uiColor: .systemBackground))
#else
        .background(Color(nsColor: .controlBackgroundColor))
#endif
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 16) {
        ConcertRowView(concert: Concert(
            id: "1",
            name: "The Eras Tour",
            artistName: "Taylor Swift",
            venueID: "venue1",
            venueName: "Madison Square Garden",
            date: Date().addingTimeInterval(86400 * 7), // 1 week from now
            minPrice: 120.0,
            maxPrice: 250.0,
            genre: "Pop",
            source: "manual",
            externalID: "ts-1"
        ))
        
        ConcertRowView(concert: Concert(
            id: "2",
            name: "Big Steppers Tour",
            artistName: "Kendrick Lamar",
            venueID: "venue2",
            venueName: "The Forum",
            date: Date().addingTimeInterval(86400 * 14), // 2 weeks from now
            minPrice: 95.0,
            maxPrice: 180.0,
            genre: "Hip Hop",
            source: "manual",
            externalID: "kl-1"
        ))
    }
    .padding()
}
