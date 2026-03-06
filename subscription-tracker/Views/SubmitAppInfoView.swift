//
//  SubmitAppInfoView.swift
//  subscription-tracker
//
//  View for submitting missing app information
//

import SwiftUI

struct SubmitAppInfoView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var paywallService: PaywallService
    
    @State private var appName = ""
    @State private var appWebsite = ""
    @State private var userEmail = ""
    @State private var isSubmitting = false
    @State private var toast: Toast?
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(L10n.Settings.submitAppInfoDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Settings.appNameLabel)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField(L10n.Settings.appNamePlaceholder, text: $appName)
                            .textInputAutocapitalization(.words)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Settings.appWebsiteLabel)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField(L10n.Settings.appWebsitePlaceholder, text: $appWebsite)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Settings.userEmailLabel)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField(L10n.Settings.userEmailPlaceholder, text: $userEmail)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }
                }
            }
            .navigationTitle(L10n.Settings.submitAppInfoTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSubmitting ? L10n.Settings.submitting : L10n.Settings.submitButton) {
                        Task {
                            await submitAppInfo()
                        }
                    }
                    .disabled(isSubmitting || appName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .toast($toast)
            .alert(L10n.Settings.appNameRequired, isPresented: $showError) {
                Button(L10n.Common.ok, role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Actions
    
    private func submitAppInfo() async {
        // Validate
        let trimmedName = appName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            errorMessage = L10n.Settings.appNameRequired
            showError = true
            return
        }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            // Get device and app info
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
            let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
            let deviceModel = UIDevice.current.model
            let systemVersion = UIDevice.current.systemVersion
            let isPro = paywallService.isProUser
            
            // Prepare data
            let data: [String: Any] = [
                "msg_type": "interactive",
                "card": [
                    "header": [
                        "title": [
                            "tag": "plain_text",
                            "content": "📱 Subora - 新应用提交 / New App Submission"
                        ],
                        "template": "blue"
                    ],
                    "elements": [
                        [
                            "tag": "div",
                            "text": [
                                "tag": "lark_md",
                                "content": "**应用信息 / App Information**"
                            ]
                        ],
                        [
                            "tag": "div",
                            "fields": [
                                [
                                    "is_short": true,
                                    "text": [
                                        "tag": "lark_md",
                                        "content": "**应用名称 / App Name:**\n\(trimmedName)"
                                    ]
                                ],
                                [
                                    "is_short": true,
                                    "text": [
                                        "tag": "lark_md",
                                        "content": "**提交时间 / Time:**\n\(formattedDate())"
                                    ]
                                ]
                            ]
                        ],
                        [
                            "tag": "div",
                            "fields": [
                                [
                                    "is_short": false,
                                    "text": [
                                        "tag": "lark_md",
                                        "content": "**官网 / Website:**\n\(appWebsite.isEmpty ? "未提供 / Not provided" : appWebsite)"
                                    ]
                                ]
                            ]
                        ],
                        [
                            "tag": "div",
                            "fields": [
                                [
                                    "is_short": false,
                                    "text": [
                                        "tag": "lark_md",
                                        "content": "**用户邮箱 / User Email:**\n\(userEmail.isEmpty ? "未提供 / Not provided" : userEmail)"
                                    ]
                                ]
                            ]
                        ],
                        [
                            "tag": "hr"
                        ],
                        [
                            "tag": "div",
                            "text": [
                                "tag": "lark_md",
                                "content": "**用户信息 / User Information**"
                            ]
                        ],
                        [
                            "tag": "div",
                            "fields": [
                                [
                                    "is_short": true,
                                    "text": [
                                        "tag": "lark_md",
                                        "content": "**App 版本 / Version:**\n\(appVersion) (\(buildNumber))"
                                    ]
                                ],
                                [
                                    "is_short": true,
                                    "text": [
                                        "tag": "lark_md",
                                        "content": "**付费状态 / Pro Status:**\n\(isPro ? "✅ Pro" : "❌ Free")"
                                    ]
                                ]
                            ]
                        ],
                        [
                            "tag": "div",
                            "fields": [
                                [
                                    "is_short": true,
                                    "text": [
                                        "tag": "lark_md",
                                        "content": "**设备型号 / Device:**\n\(deviceModel)"
                                    ]
                                ],
                                [
                                    "is_short": true,
                                    "text": [
                                        "tag": "lark_md",
                                        "content": "**系统版本 / iOS:**\n\(systemVersion)"
                                    ]
                                ]
                            ]
                        ],
                        [
                            "tag": "note",
                            "elements": [
                                [
                                    "tag": "plain_text",
                                    "content": "来自 Subora 应用 / From Subora App"
                                ]
                            ]
                        ]
                    ]
                ]
            ]
            
            // Send to Feishu webhook
            let webhookURL = "https://open.feishu.cn/open-apis/bot/v2/hook/5f4dd2f7-f2b0-41b0-ae1d-785dcec0a478"
            guard let url = URL(string: webhookURL) else {
                print("❌ Invalid webhook URL")
                throw NSError(domain: "Invalid URL", code: -1)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            request.httpBody = jsonData
            
            // Debug: Print request
            print("📤 Sending to Feishu webhook...")
            print("URL: \(webhookURL)")
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Payload: \(jsonString)")
            }
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            // Debug: Print response
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 Response status: \(httpResponse.statusCode)")
                if let responseString = String(data: responseData, encoding: .utf8) {
                    print("Response body: \(responseString)")
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("❌ HTTP Error: Invalid status code")
                throw NSError(domain: "HTTP Error", code: -1)
            }
            
            print("✅ Successfully sent to Feishu")
            
            // Success
            toast = .success(L10n.Settings.submitSuccess)
            
            // Track analytics
            AnalyticsService.shared.track("app_info_submitted", properties: [
                "app_name": trimmedName,
                "has_website": !appWebsite.isEmpty,
                "has_email": !userEmail.isEmpty,
                "is_pro_user": isPro,
                "app_version": appVersion,
                "device_model": deviceModel
            ])
            
            // Dismiss after delay
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            dismiss()
            
        } catch {
            print("❌ Error submitting app info: \(error)")
            toast = .error(L10n.Settings.submitFailed)
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

#Preview {
    SubmitAppInfoView()
}
