//
//  AppSelectionView.swift
//  subscription-tracker
//
//  App template selection view
//

import SwiftUI

struct AppSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedTemplate: AppTemplate?
    
    let onSelect: (AppTemplate?) -> Void
    
    private var filteredTemplates: [AppTemplate] {
        if searchText.isEmpty {
            return AppTemplates.all.sorted { $0.name < $1.name }
        } else {
            return AppTemplates.all
                .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                .sorted { $0.name < $1.name }
        }
    }
    
    private var groupedTemplates: [String: [AppTemplate]] {
        Dictionary(grouping: filteredTemplates, by: { $0.firstLetter })
    }
    
    private var sortedLetters: [String] {
        Array(groupedTemplates.keys).sorted()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar at top
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField(L10n.AppSelection.searchPlaceholder, text: $searchText)
                        .textFieldStyle(.plain)
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Template list
                ZStack {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 0, pinnedViews: []) {
                                ForEach(sortedLetters, id: \.self) { letter in
                                    Section {
                                        let templates = groupedTemplates[letter] ?? []
                                        ForEach(Array(templates.enumerated()), id: \.element.id) { index, template in
                                            VStack(spacing: 0) {
                                                AppTemplateRow(template: template)
                                                    .contentShape(Rectangle())
                                                    .onTapGesture {
                                                        onSelect(template)
                                                        dismiss()
                                                    }
                                                    .padding(.horizontal)

                                                if index < templates.count - 1 {
                                                    Divider()
                                                        .padding(.leading, 72)
                                                }
                                            }
                                        }
                                    } header: {
                                        Text(letter)
                                            .font(.headline)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                            .padding(.top, 16)
                                            .padding(.bottom, 4)
                                    }
                                    .id(letter)
                                }

                                // Bottom spacer for floating button
                                Spacer()
                                    .frame(height: 80)
                            }
                        }
                        .overlay(alignment: .trailing) {
                            if searchText.isEmpty {
                                AlphabetIndexView(letters: sortedLetters) { letter in
                                    withAnimation {
                                        proxy.scrollTo(letter, anchor: .top)
                                    }
                                }
                                .padding(.trailing, 4)
                            }
                        }
                    }

                    // Floating custom button at bottom
                    VStack {
                        Spacer()

                        Button {
                            onSelect(nil)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(L10n.AppSelection.createCustom)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(UIColor.systemBackground).opacity(0),
                                    Color(UIColor.systemBackground)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 80)
                            .offset(y: -40)
                        )
                    }
                }
            }
            .navigationTitle(L10n.AppSelection.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - App Template Row

private struct AppTemplateRow: View {
    let template: AppTemplate
    
    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: URL(string: template.iconURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
                    .frame(width: 44, height: 44)
            }
            
            Text(template.name)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Alphabet Index View

private struct AlphabetIndexView: View {
    let letters: [String]
    let onTap: (String) -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(letters, id: \.self) { letter in
                Text(letter)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(width: 20, height: 16)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTap(letter)
                    }
            }
        }
    }
}

#Preview {
    AppSelectionView { template in
        print("Selected: \(template?.name ?? "Custom")")
    }
}
