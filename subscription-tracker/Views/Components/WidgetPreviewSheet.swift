//
//  WidgetPreviewSheet.swift
//  subscription-tracker
//
//  Widget preview sheet showing all three sizes and setup instructions.
//

import SwiftUI

struct WidgetPreviewSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Small widget preview
                    widgetPreview(title: "Small") {
                        SmallPreview()
                    }
                    .frame(width: 170, height: 170)

                    // Medium widget preview
                    widgetPreview(title: "Medium") {
                        MediumPreview()
                    }
                    .frame(width: 364, height: 170)

                    // Large widget preview
                    widgetPreview(title: "Large") {
                        LargePreview()
                    }
                    .frame(width: 364, height: 376)

                    // How to add instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How to Add")
                            .font(.headline)

                        StepRow(number: 1, text: L10n.Settings.widgetStep1)
                        StepRow(number: 2, text: L10n.Settings.widgetStep2)
                        StepRow(number: 3, text: L10n.Settings.widgetStep3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .padding(.top, 16)
            }
            .navigationTitle(L10n.Settings.widgetPreviewTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.Common.done) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func widgetPreview<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 8) {
            content()
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Widget Previews (static mockups matching actual widget appearance)

private struct SmallPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.caption)
                    .foregroundStyle(.blue)
                Text("Subora")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("$82.96")
                .font(.title2)
                .fontWeight(.bold)
            Text("per month")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 4) {
                Circle()
                    .fill(Color(red: 1, green: 0.176, blue: 0.333))
                    .frame(width: 6, height: 6)
                Text("Netflix")
                    .font(.caption2)
                Spacer()
                Text("in 3d")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
    }
}

private struct MediumPreview: View {
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("Subora")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("$82.96")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("per month")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("6 active")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(.quaternary)
                .frame(width: 1)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 6) {
                Text("Upcoming")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                mockRow("Netflix", color: Color(red: 1, green: 0.176, blue: 0.333), days: "in 3d")
                mockRow("Spotify", color: Color(red: 1, green: 0.176, blue: 0.333), days: "in 7d")
                mockRow("iCloud+", color: Color(red: 0, green: 0.478, blue: 1), days: "in 12d")
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
    }

    private func mockRow(_ name: String, color: Color, days: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(name)
                .font(.caption2)
                .fontWeight(.medium)
            Spacer()
            Text(days)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

private struct LargePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "creditcard.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("Subora")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("6 active")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("$82.96")
                    .font(.title)
                    .fontWeight(.bold)
                Text("/mo")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Text("Upcoming Renewals")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            detailRow("Netflix", price: "$15.99/mo", days: "in 3d", color: Color(red: 1, green: 0.176, blue: 0.333))
            detailRow("Spotify", price: "$9.99/mo", days: "in 7d", color: Color(red: 1, green: 0.176, blue: 0.333))
            detailRow("iCloud+", price: "$2.99/mo", days: "in 12d", color: Color(red: 0, green: 0.478, blue: 1))
            detailRow("ChatGPT Plus", price: "$20.00/mo", days: "in 15d", color: Color(red: 0.686, green: 0.322, blue: 0.871))
            detailRow("YouTube Premium", price: "$13.99/mo", days: "in 20d", color: Color(red: 1, green: 0.176, blue: 0.333))
            detailRow("Claude Pro", price: "$20.00/mo", days: "in 25d", color: Color(red: 0.686, green: 0.322, blue: 0.871))

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
    }

    private func detailRow(_ name: String, price: String, days: String, color: Color) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 3, height: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(price)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(days)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Step Row

private struct StepRow: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(.blue))

            Text(text)
                .font(.subheadline)
        }
    }
}
