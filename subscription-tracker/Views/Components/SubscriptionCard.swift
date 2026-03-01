import SwiftUI

/// 订阅卡片组件
/// 显示订阅信息，支持左滑操作（编辑、删除、归档）
struct SubscriptionCard: View {
    let subscription: Subscription
    let onEdit: () -> Void
    let onArchive: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // App icon or category color indicator
            if let iconURL = subscription.iconURL, let url = URL(string: iconURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 44, height: 44)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 44, height: 44)
                            .cornerRadius(10)
                    case .failure:
                        defaultIcon
                    @unknown default:
                        defaultIcon
                    }
                }
            } else if let category = subscription.category {
                // Category color indicator
                RoundedRectangle(cornerRadius: 2)
                    .fill(category.color)
                    .frame(width: 4)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // 订阅名称和分类
                HStack {
                    Text(subscription.name)
                        .font(.headline)
                    
                    if let category = subscription.category {
                        CategoryBadge(category: category)
                    }
                    
                    Spacer()
                }
                
                // 金额和周期
                Text(formatAmount())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // 下次续费日期
                HStack {
                    Text(L10n.Subscriptions.nextRenewal(formatDate(subscription.nextBillingDate)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // 倒计时
                    if let daysUntil = daysUntilRenewal() {
                        let dayText = daysUntil == 1 ? L10n.Insights.daysSuffixSingular : L10n.Insights.daysSuffix
                        Text(daysUntil > 0 ? "\(daysUntil) \(dayText)" : L10n.Subscriptions.today)
                            .font(.caption)
                            .foregroundColor(daysUntil <= 3 ? .red : .secondary)
                    }
                }
            }
            
            // 右箭头
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label(L10n.Common.delete, systemImage: "trash")
            }
            
            Button {
                onArchive()
            } label: {
                Label(subscription.archived ? L10n.SubscriptionDetail.unarchive : L10n.SubscriptionDetail.archive, systemImage: "archivebox")
            }
            .tint(.orange)
        }
    }
    
    // MARK: - Helper Views
    
    private var defaultIcon: some View {
        Image(systemName: "app.fill")
            .font(.system(size: 24))
            .foregroundColor(.secondary)
            .frame(width: 44, height: 44)
            .background(Color(.systemGray5))
            .cornerRadius(10)
    }
    
    // MARK: - Helper Methods
    
    private func formatAmount() -> String {
        let formattedAmount = CurrencyFormatter.format(
            amount: subscription.amount,
            currency: subscription.currency
        )
        let cycleText = formatBillingCycle()
        return "\(formattedAmount) / \(cycleText)"
    }
    
    private func formatBillingCycle() -> String {
        L10n.BillingCycle.formatCycle(subscription.billingCycle, subscription.billingCycleUnit)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func daysUntilRenewal() -> Int? {
        Calendar.current.dateComponents(
            [.day],
            from: Date(),
            to: subscription.nextBillingDate
        ).day
    }
}

#Preview {
    let category = Category(name: "娱乐", colorHex: "#FF5733")
    let subscription = Subscription(
        name: "Netflix",
        description: "流媒体视频服务",
        category: category,
        firstPaymentDate: Date(),
        billingCycle: 1,
        billingCycleUnit: .month,
        amount: 15.99,
        currency: "USD"
    )
    
    return List {
        SubscriptionCard(
            subscription: subscription,
            onEdit: {},
            onArchive: {},
            onDelete: {}
        )
    }
    .listStyle(.plain)
}
